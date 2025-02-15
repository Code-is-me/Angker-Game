class_name Trash
extends CharacterBody2D


@export var damping: float = 50.0


func _physics_process(delta: float):
	if not multiplayer.is_server():
		return
	velocity = velocity.move_toward(Vector2.ZERO, damping * delta)
	move_and_slide()

func give_velocity(vel: Vector2):
	if vel.length_squared() >= velocity.length_squared():
		velocity += vel
		velocity = velocity.limit_length(vel.length())
