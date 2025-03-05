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
		body.object_to_interact = self

func _on_i_body_exited(body: Node2D) -> void:
	if body is GameCharacter:
		if body.object_to_interact == self:
			body.object_to_interact = null
