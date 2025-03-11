class_name GameCharacter 
extends CharacterBody2D

enum AnimDir {LEFT, UP, DOWN}


@export var max_accel: float = 3500.0
@export var movement_speed : float = 500
@export var current_character: bool
@export var player_id: int:
	set(value):
		player_id = value
		$InputSynchronizer.set_multiplayer_authority(value)

var character_direction: Vector2:
	set(value):
		if value.length_squared() > 0.0:
			last_nonzero_character_direction = value
		character_direction = value
var last_nonzero_character_direction: Vector2
var do_interact: bool
var do_use: bool
var anim_state: String = ""
var anim_dir: AnimDir = AnimDir.DOWN

var object_to_interact_list: Array[InteractibleObject]
var object_to_interact_rem_list: Array[InteractibleObject]
var held_pickable_object: PickableInteractibleObject



func _enter_tree() -> void:
	if player_id == 0:
		player_id = int(str(name))
	current_character = player_id == multiplayer.get_unique_id()
	$Camera2D.enabled = current_character
	print("Multiplayer unique id: ", multiplayer.get_unique_id(), ", player_id: ", player_id)

func _physics_process(delta: float) -> void:
	character_direction = $InputSynchronizer.character_direction
	if multiplayer.is_server():
		_apply_movements(delta)
	_apply_animations()

func _apply_movements(delta: float) -> void:
	velocity = velocity.move_toward(character_direction * movement_speed, max_accel * delta)
	if do_interact:
		interact_with_object()
		do_interact = false
	if do_use:
		use_held_object()
		do_use = false

	move_and_slide()

func _apply_animations():

  # flip (true/false dibalik karena normalnya ke kiri bukan ke kanan)
	if character_direction.x > 0: %sprite.flip_h = true
	elif character_direction.x < 0:  %sprite.flip_h = false
 
	if character_direction:
		var dir: float = get_direction_angle()
		anim_dir = [AnimDir.LEFT, AnimDir.DOWN, AnimDir.LEFT, AnimDir.UP][int(snapped(dir, 90.0)/90.0)]
		anim_state = "Walking"
	else:
		anim_state = "Idle"
  
	var anim_to_play: String = anim_state + ["Left", "Up", "Down"][anim_dir]
	if %sprite.animation != anim_to_play or not %sprite.is_playing():
		%sprite.play(anim_to_play)


func interact_with_object() -> void:
	print(object_to_interact_list)
	if !object_to_interact_list.is_empty():
		object_to_interact_list[0].interact(self)

func use_held_object() -> void:
	if is_instance_valid(held_pickable_object):
		held_pickable_object.use()
  
func get_direction_angle() -> float:
	return rad_to_deg(atan2(last_nonzero_character_direction.y, last_nonzero_character_direction.x))

func add_interactible_object_to_list(interactible_object: InteractibleObject) -> void:
	var obj_in_rem_idx: int = object_to_interact_rem_list.find(interactible_object)
	if obj_in_rem_idx==-1:
		object_to_interact_list.append(interactible_object)
	else:
		object_to_interact_rem_list.remove_at(obj_in_rem_idx)

func remove_interactible_object_from_list(interactible_object: InteractibleObject) -> void:
	var obj_idx: int = object_to_interact_list.find(interactible_object)
	if obj_idx != -1:
		object_to_interact_list.remove_at(obj_idx)
	else:
		object_to_interact_rem_list.append(interactible_object)
