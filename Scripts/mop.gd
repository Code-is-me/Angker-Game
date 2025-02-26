extends PickableInteractibleObject


func _on_used() -> void:
	var cleaner: Area2D = load("res://Scenes/cleaner.tscn").instantiate()
	cleaner.global_position = global_position
	GameManager.instance.add_child(cleaner)
