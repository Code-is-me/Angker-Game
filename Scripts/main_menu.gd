extends MarginContainer

func play():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Label.visible = false
	%LineEdit.visible = false
func to_shop() -> void:
	get_tree().change_scene_to_file("res://Scenes/shop_menu.tscn")

func play_as_host():
	MultiplayerManager.become_host(%Label)
	%Label.visible = true


func join_host():
	if %LineEdit.visible:
		MultiplayerManager.join_host(%LineEdit.text)
	else:
		%LineEdit.visible = true
