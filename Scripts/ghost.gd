class_name Ghost 
extends GameCharacter

static var instance: Ghost

func _enter_tree() -> void:
	if not multiplayer.is_server():
		$Area2D.queue_free()
	super._enter_tree()
	

	
	print(current_character)
	instance = self
	if not current_character:
		%sprite.self_modulate.a = 0.25
		
func check_for_player(body: Node2D) -> void:
	if body is Player:
		body.stun.rpc()
		
func interact_with_object() -> void:
	super.interact_with_object()
	if multiplayer.is_server() and not is_instance_valid(object_to_interact):
		for body: Node2D in $Area2D.get_overlapping_bodies():
			if body is Player:
				body.stun.rpc()
				break
