class_name InteractibleObject
extends Area2D


func _on_interact_with_gc(gc: GameCharacter) -> void:
	pass
  
func interact(gc: GameCharacter) -> void:
	_on_interact_with_gc(gc)
  
func _ready() -> void:
	body_entered.connect(_on_i_body_entered)
	body_exited.connect(_on_i_body_exited)

func _on_i_body_entered(body: Node2D) -> void:
	if body is GameCharacter:
		body.add_interactible_object_to_list(self)
		print(body, " enters ", self)
		print("oti list: ", body.object_to_interact_list)
		print("oti rem list: ", body.object_to_interact_rem_list)

func _on_i_body_exited(body: Node2D) -> void:
	if body is GameCharacter:
		body.remove_interactible_object_from_list(self)
		print(body, " exits ", self)
		print("oti list: ", body.object_to_interact_list)
		print("oti rem list: ", body.object_to_interact_rem_list)
