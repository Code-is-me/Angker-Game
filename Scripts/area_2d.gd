class_name PickableInteractibleObject
extends InteractibleObject

var picked_up: bool = false:
	set(value):
		set_physics_process(value)
		picked_up = value

func _ready():
	super._ready()
	picked_up = false

func _physics_process(_delta: float) -> void:
	global_position = Player.instance.global_position

func _on_interact_with_player() -> void:
	picked_up = not picked_up
	Player.instance.held_pickable_object = self if picked_up else null

func use():
	_on_used()

func _on_used():
	pass
