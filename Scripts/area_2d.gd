class_name PickableInteractibleObject
extends InteractibleObject


@export var pickable_by_player: bool = true
@export var pickable_by_ghost: bool = false
@export var item_type: GameManager.Item

var picking_up_gc: GameCharacter = null:
	set(value):
		set_physics_process(is_instance_valid(value))
		picking_up_gc = value

func _ready():
	super._ready()
	picking_up_gc = null

func _physics_process(_delta: float) -> void:
	global_position = picking_up_gc.global_position

func _on_interact_with_gc(gc: GameCharacter) -> void:
	if (gc is Player and !pickable_by_player) or (gc is Ghost and !pickable_by_ghost):
		return
	var held: bool = gc.held_pickable_object == self
	if not held:
		picking_up_gc = gc
		gc. held_pickable_object = self
		add_to_inventory.rpc_id(gc.player_id)
	else:
		picking_up_gc = null
		gc. held_pickable_object = null
		remove_from_inventory.rpc_id(gc.player_id)

func use():
	_on_used()

func _on_used():
	pass

@rpc("call_local")
func add_to_inventory() -> void:
	GameManager.instance.add_item_to_inventory(item_type, {"object": self})
	GameManager.instance.item_pressed.connect(check_for_use)

@rpc("call_local")
func remove_from_inventory() -> void:
	GameManager.instance.remove_item_from_inventory(item_type)
	GameManager.instance.item_pressed.disconnect(check_for_use)

func check_for_use(item: GameManager.Item) -> void:
	print("Using item: ", item)
	if item == item_type:
		call_use.rpc_id(1)


@rpc("any_peer", "call_local")
func call_use() -> void:
	use() 
