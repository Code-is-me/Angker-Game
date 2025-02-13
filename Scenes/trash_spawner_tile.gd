extends Node2D


func _ready() -> void:
	if not multiplayer.is_server():
		return
	for i in randi_range(1, 2):
		var trash: Trash = preload("res://Scenes/trash.tscn").instantiate()
		trash.global_position = global_position +  Vector2(randf_range(-12.0, 12.0), randf_range(-12.0, 12.0))
		get_parent().get_node("Trashes").add_child(trash, true)
