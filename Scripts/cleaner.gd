extends Area2D


func _ready() -> void:
	await get_tree().create_timer(0.125, false, true).timeout
	print(get_overlapping_areas())
	for area: Area2D in get_overlapping_areas():
		if area is Dirt:
			area.clean.rpc()
	queue_free()
