extends Node2D


func _ready() -> void:
	if not multiplayer.is_server():
		return
	for i in randi_range(1, 3):
		var dirt: Dirt = preload("res://Scenes/dirt.tscn").instantiate()
		get_tree().current_scene.get_node("Dirts").add_child(dirt, true)
		dirt.setup_global_position.rpc(global_position +  Vector2(randf_range(-12.0, 12.0), randf_range(-12.0, 12.0)))
