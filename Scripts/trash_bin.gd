extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if area is Trash:
		if not multiplayer.is_server():
			return
		remove_trash.rpc(NodePath(area.name))

@rpc("authority", "call_local")
func remove_trash(trash_path: NodePath) -> void:
	get_parent().get_node(trash_path).queue_free()
