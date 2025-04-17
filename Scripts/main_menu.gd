extends MarginContainer

func play():
	MultiplayerManager.joining_player_ids.append(1)
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(OS.get_user_data_dir())
	%Label.visible = false
	%LineEdit.visible = false
	
func to_shop() -> void:
	get_tree().change_scene_to_file("res://Scenes/shop_menu.tscn")

func open_settings() -> void:
	var settings_instance: Node = load("res://Scenes/settings.tscn").instantiate()
	add_child(settings_instance)

func play_as_host():
	MultiplayerManager.create_lobby(%Label)
	%Label.visible = true


func join_host():
	if %LineEdit.visible:
		MultiplayerManager.join_host(%LineEdit.text)
	else:
		%LineEdit.visible = true


func copy_address() -> void:
	DisplayServer.clipboard_set(MultiplayerManager.created_room_id)
