extends Node


const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var joining_player_ids: PackedInt64Array = []
var players_spawn_node: Node2D:
	set(value):
		players_spawn_node = value
		if multiplayer.is_server():
			var player_scenes: Array[PackedScene] = [preload("res://Scenes/player.tscn"), preload("res://Scenes/ghost.tscn")]
			player_scenes.shuffle()
			for id in PackedInt64Array([1]) + joining_player_ids:
				_add_player_to_game (player_scenes.pop_back(), id)
				



func become_host() -> void:
	print("Starting host!")
  
	var server_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

	server_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = server_peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_remove_player_from_game)


func join_as_player_2() -> void:
	print("Player 2 joining!")
	change_to_game_scene()
	var client_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

	client_peer.create_client(SERVER_IP, SERVER_PORT)

	multiplayer.multiplayer_peer = client_peer

func change_to_game_scene() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_peer_connected(id: int) -> void:
	print("Player with id %d joined the game!" % id)
	joining_player_ids.append(id)
	change_to_game_scene()
	await get_tree().process_frame
	

func _add_player_to_game(character_scene: PackedScene, id: int) -> void:
	var instance: GameCharacter = character_scene.instantiate()
	instance.name = "Player%d" % id
	instance.player_id = id
	players_spawn_node.add_child(instance, true)
	instance.global_position = Vector2(randf_range(-200.0, 200.0), randf_range(-200.0, 200.0))
	


func _remove_player_from_game(id: int) -> void:
	print("Player with id %d left the game!" % id)
