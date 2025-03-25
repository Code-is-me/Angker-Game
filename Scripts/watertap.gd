extends InteractibleObject


var watertap_on: bool:
	set(value):
		update_according_to_faucet_on_status(value)
		watertap_on = value
@onready var initial_watersprite_scale: float = $Water.scale.y
@onready var watersprite_initial_pos_y = $Water.position.y
@onready var watersprite_y_offset = (watersprite_initial_pos_y - $Water.scale.y * DISTANCE_TO_WTRBTM * 0.5)

const DISTANCE_TO_WTRBTM = 15.0


func _ready() -> void:
	super._ready()
	update_according_to_faucet_on_status(watertap_on)
	if !multiplayer.is_server():
		$Area2D.queue_free()

func _physics_process(delta: float):
	var highest_bucket: Bucket = null
	var highest_pos_y: float = INF
	for body: Node2D in $Area2D.get_overlapping_areas():
		if body is Bucket:
			var current_pos_y: float = body.global_position.y
			if current_pos_y < highest_pos_y:
				highest_pos_y = current_pos_y
				highest_bucket = body

	if highest_bucket != null:
		var wv: float = minf(50.0 * delta, highest_bucket.max_water - highest_bucket.remaining_water_volume)
		highest_bucket.take_water(-wv)
		set_watersprite_height.rpc(highest_pos_y - global_position.y - watersprite_y_offset)
	else:
		set_watersprite_height.rpc(DISTANCE_TO_WTRBTM)
		
@rpc("call_local")
func set_watersprite_height(y_diff_to_target: float) -> void:
	$Water.scale.y = y_diff_to_target / DISTANCE_TO_WTRBTM
	$Water.position.y = y_diff_to_target * 0.5 + watersprite_y_offset

@rpc("call_local", "reliable")
func set_faucet_on_status(wo: bool) -> void:
	watertap_on = wo

func update_according_to_faucet_on_status(faucet_on: bool) -> void:
	print_stack()
	print(faucet_on, ", in peer: ", multiplayer.get_unique_id())
	$Water.visible = faucet_on
	var pp: bool = false
	if multiplayer.is_server():
		pp = faucet_on
		$Area2D/WaterCollision.disabled = !faucet_on
	set_physics_process(pp)
  
func _on_interact_with_gc(gc: GameCharacter) -> void:
	print("Interacting with gc: ", gc, ", faucet on status: ", watertap_on, ", on peer: ", multiplayer.get_unique_id())
	set_faucet_on_status.rpc(!watertap_on)
