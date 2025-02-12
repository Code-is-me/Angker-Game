extends PickableInteractibleObject


func _on_used():
	print("Sedang menyapu ...") # Kita akan ganti ini apabila telah mengimplementasikan lantai kotor sesungguhnya.
	var broom_push: Area2D = preload("res://Scenes/broom_push.tscn").instantiate()
	broom_push.rotation_degrees = Player.instance.get_direction_angle()
	broom_push.position = position
	add_sibling(broom_push)
