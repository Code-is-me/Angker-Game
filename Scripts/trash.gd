class_name Trash
extends CharacterBody2D


@export var damping: float = 50.0


func _physics_process(delta: float):
	if not multiplayer.is_server():
		return
	velocity = velocity.move_toward(Vector2.ZERO, damping * delta)
	var lst_vel: Vector2 = velocity
	move_and_slide()
	var last_slide_collision: KinematicCollision2D = get_last_slide_collision()
	if last_slide_collision != null:
		if not (last_slide_collision.get_collider() is CharacterBody2D):
			velocity = (lst_vel * 0.5).bounce(last_slide_collision.get_normal())

func give_velocity(vel: Vector2):
	if vel.length_squared() >= velocity.length_squared():
		velocity += vel
		velocity = velocity.limit_length(vel.length())
