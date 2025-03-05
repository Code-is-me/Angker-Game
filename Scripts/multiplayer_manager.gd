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
			for id in joining_player_ids:
				_add_player_to_game (player_scenes.pop_back(), id)
		

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		become_host(null, true)

func become_host(output_label: Label, dedicated: bool = false) -> void:
	print("Starting host!")
  
	var server_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_remove_player_from_game)
	if not dedicated:
		joining_player_ids.append(1)


func join_host(host_address: String) -> void:
	print("Player 2 joining!")
	change_to_game_scene()
	var client_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	client_peer.create_client(host_address, SERVER_PORT)

	multiplayer.multiplayer_peer = client_peer

func change_to_game_scene() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_peer_connected(id: int) -> void:
	print("Player with id %d joined the game!" % id)
	joining_player_ids.append(id)
	if joining_player_ids.size() >= 2:
		await get_tree().process_frame
		change_to_game_scene()
  

func _add_player_to_game(character_scene: PackedScene, id: int) -> void:
	var instance: GameCharacter = character_scene.instantiate()
	instance.name = "Player%d" % id
	instance.player_id = id
	players_spawn_node.add_child(instance, true)
	instance.global_position = Vector2(randf_range(-200.0, 200.0), randf_range(-200.0, 200.0))
  


func _remove_player_from_game(id: int) -> void:
	print("Player with id %d left the game!" % id)
	var idx: int = joining_player_ids.find(id)
	if idx != -1:
		joining_player_ids.remove_at(idx)
	if is_instance_valid(players_spawn_node):
		var gc: GameCharacter = players_spawn_node.get_node_or_null("Player%d" % id)
		if gc:
			gc.queue_free()
