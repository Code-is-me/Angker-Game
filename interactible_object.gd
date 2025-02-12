class_name InteractibleObject
extends Area2D


func _on_interact_with_player() -> void:
	pass
	
func interact():
	_on_interact_with_player()
	
func _ready():
	body_entered.connect(_on_i_body_entered)
	body_exited.connect(_on_i_body_exited)

func _on_i_body_entered(body: Node2D) -> void:
	if body is Player:
		body.object_to_interact = self

func _on_i_body_exited(body: Node2D) -> void:
	if body is Player:
		if body.object_to_interact == self:
			body.object_to_interact = null
