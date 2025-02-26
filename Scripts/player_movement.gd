class_name Player 
extends GameCharacter
var stun_time_left:float
@onready var normal_movement_speed: float = movement_speed
static var instance: Player

func _ready():
	instance = self
	%StunEffect.emitting = false
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if multiplayer.is_server():
		if stun_time_left > 0.0:
			stun_time_left -= delta
			if stun_time_left <= 0.0:
				destun.rpc()
				
@rpc("call_local")
func stun() -> void:
	movement_speed=normal_movement_speed*0.375
	if multiplayer.is_server():
		stun_time_left= 3.0
	if current_character:
		GameManager.instance.hud.add_child(load("res://Scenes/jumpscare.tscn").instantiate())
		%StunEffect.emitting = true
		
@rpc("call_local")
func destun()->void:
	movement_speed=normal_movement_speed
	%StunEffect.emitting = false
		
		
