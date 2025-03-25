class_name PickableInteractibleObject
extends InteractibleObject


@export var display_item_in_inventory: bool = true
@export var pickable_by_player: bool = true
@export var pickable_by_ghost: bool = false
@export var item_type: GameManager.Item


var _picking_up_gc: GameCharacter
var picking_up_gc: GameCharacter = null:
	set(value):
		if multiplayer.is_server():
			var object_exists: bool = is_instance_valid(value)
			_s_pckngup_gc.rpc(get_path_to(value) if object_exists else "")
		else:
			printerr("Cannot set 'picking_up_gc' from a non server side. Multiplayer unique id: ", multiplayer.get_unique_id())
	get:
		return _picking_up_gc

func _ready() -> void:
	super._ready()
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	global_position = _picking_up_gc.global_position

func _on_interact_with_gc(gc: GameCharacter) -> void:
	if (gc is Player and !pickable_by_player) or (gc is Ghost and !pickable_by_ghost):
		return
	var held: bool = gc.held_pickable_object == self
	if not held:
		if is_instance_valid(gc.held_pickable_object):
			gc.held_pickable_object.interact(gc)
		picking_up_gc = gc
		gc. held_pickable_object = self
		if display_item_in_inventory:
			add_to_inventory.rpc_id(gc.player_id)
	else:
		picking_up_gc = null
		gc. held_pickable_object = null
		if display_item_in_inventory:
			remove_from_inventory.rpc_id(gc.player_id)

func use() -> void:
	_on_used()

func _on_used() -> void:
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

@rpc("call_local")
func _s_pckngup_gc(np: String) -> void:
	set_physics_process(!np.is_empty())
	_picking_up_gc = null if np.is_empty() else get_node(np)
