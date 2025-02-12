class_name Trash
extends Area2D


@export var damping: float = 50.0

var velocity: Vector2


func _physics_process(delta: float):
	position += velocity * delta
	velocity = velocity.move_toward(Vector2.ZERO, damping * delta)

func give_velocity(vel: Vector2):
	if vel.length_squared() >= velocity.length_squared():
		velocity += vel
		velocity = velocity.limit_length(vel.length())
