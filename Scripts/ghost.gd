class_name Ghost 
extends GameCharacter

static var instance: Ghost

func _enter_tree() -> void:
	if multiplayer.is_server():
		$Area2D.body_entered.connect(check_for_player)
	else:
		$Area2D.queue_free()
	super._enter_tree()
	
	print(current_character)
	instance = self
	if not current_character:
		%sprite.self_modulate.a = 0.25
		
func check_for_player(body: Node2D) -> void:
	if body is Player:
		body.stun.rpc()
