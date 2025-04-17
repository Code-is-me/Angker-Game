extends Node


const SERVER_PORT = 7777
#const SERVER_IP = "127.0.0.1"

var joining_player_ids: PackedInt64Array = []
var players_spawn_node: Node2D:
	set(value):
		players_spawn_node = value
		if multiplayer.is_server():
			var player_scenes: Array[PackedScene] = [preload("res://Scenes/player.tscn"), preload("res://Scenes/ghost.tscn")]
			player_scenes.shuffle()
			for id in joining_player_ids:
				_add_player_to_game (player_scenes.pop_back(), id)

var player_nickname: String = "Nickname"
var lobby_short_code: String = "1234"
var login_token: String = ""

var created_room_id: String

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		become_host(null, true)
	else:
		login()

func become_host(output_label: Label, dedicated: bool = false) -> void:
	print("Starting host!")
  
	var server_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_remove_player_from_game)
	if not dedicated:
		joining_player_ids.append(1)

func create_lobby(output_label: Label) -> bool:
	# Create a public lobby using a previously obtained playerAuth token
	# The function will pause until a result is obtained
	var res = await HathoraSDK.lobby_v3.create(login_token, Hathora.Visibility.PUBLIC, Hathora.Region.SINGAPORE).async()
	
	# Having obtained a result, the function continues
	# If there was an error, store the error message and return
	if res.is_error():
		var error_msg: String = res.as_error().message
		output_label.modulate = Color.RED
		output_label.text = error_msg
		return false

	# Store the data contained in the Result
	var lobby_data = res.get_data()
	created_room_id = lobby_data.roomId
	print("Created lobby with roomId ", lobby_data.roomId)
	output_label.modulate = Color.BLACK
	output_label.text = created_room_id
	await get_tree().create_timer(8.0).timeout
	join_room_id(created_room_id)
	return true

func login() -> void:
	var res = await HathoraSDK.auth_v1.login_anonymous().async()
	if res.is_error():
		printerr("Error login: ", res.as_error().message)
		return

	login_token = res.get_data().token
	

# Player requesting to join a lobby
func _on_join_lobby_requested() -> void:
	# Logging in the player
	if login_token.is_empty():
		login()

	# Getting the roomId from the lobby shortCode
	var res = await HathoraSDK.lobby_v3.get_info_by_short_code(login_token, lobby_short_code).async()
	if res.is_error():
		print(res.as_error().message)
		return

	join_room_id(res.get_data().roomId)
	
# Joining the room by its roomId
func join_room_id(room_id: String) -> void:
	
	# Getting the connection info for the room
	var res = await HathoraSDK.room_v2.get_connection_info(room_id).async()
	if res.is_error():
		printerr("Error creating room: ", res.as_error().message)
		return

	var connection_info = res.get_data()

	# If the roomStatus is not yet ACTIVE, we try again
	if connection_info.status != Hathora.RoomStatus.ACTIVE:
		join_room_id(room_id)
		return
	
	# Creating a multiplayer peer using the exposed host and port
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_client(connection_info.exposedPort.host, connection_info.exposedPort.port)
	if err:
		printerr("Error creating client peer to join the room. Error: ", error_string(err))
		return

	multiplayer.multiplayer_peer = peer
	await multiplayer.connected_to_server
	change_to_game_scene()
	print("Connected!")

func join_host(id: String) -> void:
	join_room_id(id)

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
