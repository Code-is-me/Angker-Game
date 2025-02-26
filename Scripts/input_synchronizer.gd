extends MultiplayerSynchronizer


@export var character_direction: Vector2
@onready var game_character: GameCharacter = get_parent()


func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _physics_process(_delta: float) -> void:
	if Joystick.pos_vector.is_zero_approx():
		character_direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	else:
		character_direction = Joystick.pos_vector

	if Input.is_action_just_pressed("interact"):
		interact.rpc()
	if Input.is_action_just_pressed("use"):
		use.rpc()

@rpc("call_local")
func interact() -> void:
	if multiplayer.is_server():
		game_character.do_interact = true

@rpc("call_local")
func use() -> void:
	if multiplayer.is_server():
		game_character.do_use = true
