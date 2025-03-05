extends Sprite2D


@onready var joystick: Joystick = $".."

var pressing: bool = false

@export var max_length: float = 150.0
@export var deadzone: float = 0.05


func _ready() -> void:
	max_length *= joystick.scale.x
 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pressing = joystick.get_node(^"TouchScreenButton").is_pressed()
	if pressing: # If the finger is on screen
		if get_global_mouse_position().distance_to(joystick.global_position) <= max_length:
	# Checks if the joystick is still in the circle and position the num
			global_position = get_global_mouse_position()
		else:
			# If the finger has passed the circle but is still being pressed
			# Calculate the angle to the mouse and set the knob to max length based on the angle
			var angle: float = joystick.global_position.angle_to_point(get_global_mouse_position())
			global_position.x = joystick.global_position.x + cos(angle) * max_length
			global_position.y = joystick.global_position.y + sin(angle) * max_length
		calculate_vector()
	else:
		global_position = lerp(global_position, joystick.global_position, 1.0 - 0.0001**delta) # More accurate framerate-independent lerp.
		Joystick.pos_vector = Vector2.ZERO


func calculate_vector() -> void:
	var relative_pos: Vector2 = global_position - joystick.global_position
	var relative_length: float = relative_pos.length() / max_length
	if relative_length >= deadzone:
		Joystick.pos_vector = relative_pos.normalized()
		if relative_length < 0.4:
			Joystick.pos_vector *= relative_length / 0.4
	global_position = Joystick.pos_vector * max_length + joystick.global_position
