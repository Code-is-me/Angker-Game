extends Area2D


func _ready() -> void:
	for area: Area2D in get_overlapping_areas():
		if area is Dirt:
			area.clean.rpc()
	queue_free()
