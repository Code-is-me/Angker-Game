class_name Ghost 
extends GameCharacter

static var instance: Ghost

func _enter_tree() -> void:
	super._enter_tree()
	print(current_character)
	instance = self
	if not current_character:
		$Sprite.self_modulate.a = 0.25
