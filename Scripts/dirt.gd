class_name Dirt
extends Area2D


var level: int:
	set(value):
		if value <= 0:
			queue_free()
		modulate.a = 0.2 * value
		level = value


func _ready() -> void:
	if multiplayer.is_server():
		setup.rpc(randi_range(2, 5), randf_range(0.0, TAU))
		
@rpc("call_local")
func setup(lvl: int, rot: float) -> void:
	level = lvl
	rotation = rot
	
@rpc("call_local")
func clean() -> void:
	level -= 1
