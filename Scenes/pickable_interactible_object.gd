extends PickableInteractibleObject


func _ready() -> void:
	super._ready()
	item_dropped.connect(check_for_trap.unbind(1))

func check_for_trap() -> void:
	if multiplayer.is_server():
		for b: Node2D in get_overlapping_bodies():
			if b is Player:
				global_position = b.global_position
				b.trap.rpc()
				break
	print("Overlapping bodies: ", get_overlapping_bodies())
