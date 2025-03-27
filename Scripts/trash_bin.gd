extends Area2D


func _ready() -> void:
	if multiplayer.is_server():
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Trash:
		remove_trash.rpc(get_path_to(body))

@rpc("authority", "call_local")
func remove_trash(trash_path: NodePath) -> void:
	var fire_effect: Node2D = preload("res://Scenes/cpu_particles_2d.tscn").instantiate()
	fire_effect.global_position = $Marker2D.global_position
	add_sibling(fire_effect)
	get_node(trash_path).queue_free()
