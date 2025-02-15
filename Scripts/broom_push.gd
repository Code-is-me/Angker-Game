extends Area2D

@export var max_distance = 12.0
@export var speed: float = 55.0

func _ready():
	get_tree().create_timer(max_distance / speed).timeout.connect(queue_free) # Waktu = Jarak / Kecepatan

func _physics_process(delta: float) -> void:
	var last_pos: Vector2 = position
	move_local_x(speed * delta)
	var velocity_vector: Vector2 = (position - last_pos) / delta
	for body: Node2D in get_overlapping_bodies():
		if body is Trash:
			body.give_velocity(velocity_vector)
