extends MarginContainer

func play():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func to_shop() -> void:
	get_tree().change_scene_to_file("res://Scenes/shop_menu.tscn")

func play_as_host():
	MultiplayerManager.become_host()


func join_host():
	MultiplayerManager.join_as_player_2()
