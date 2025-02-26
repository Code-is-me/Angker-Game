extends Node


const NORAY_ADDRESS = "tomfol.io"
const NORAY_PORT = 8890
const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var is_host: bool = false
var external_oid: String
var joining_player_ids: PackedInt64Array = []
var players_spawn_node: Node2D:
	set(value):
		players_spawn_node = value
		if multiplayer.is_server():
			var player_scenes: Array[PackedScene] = [preload("res://Scenes/player.tscn"), preload("res://Scenes/ghost.tscn")]
			player_scenes.shuffle()
			for id in PackedInt64Array([1]) + joining_player_ids:
				_add_player_to_game (player_scenes.pop_back(), id)
var has_noray_connected: bool = false

signal noray_connected
		

func _ready() -> void:
	Noray.on_connect_to_host.connect(on_noray_connected)
	Noray.on_connect_nat.connect(handle_nat_connection)
	Noray.on_connect_relay.connect(handle_relay_connection)
	Noray.connect_to_host(NORAY_ADDRESS, NORAY_PORT)

func on_noray_connected() -> void:
	print("Connected to Noray server")
	Noray.register_host()
	await Noray.on_pid
	await Noray.register_remote()
	has_noray_connected = true
	noray_connected.emit()


func become_host(output_label: Label) -> void:
	print("Starting host!")
	
	if !has_noray_connected:
		await noray_connected
	var server_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

	is_host = true
	server_peer.create_server(Noray.local_port)
	multiplayer.multiplayer_peer = server_peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_remove_player_from_game)
	output_label.modulate = Color.BLACK
	#setup_upnp(SERVER_PORT, output_label)


func join_host(host_address: String) -> void:
	external_oid = host_address
	Noray.connect_nat(host_address)
	print("Player 2 joining!")

func create_client(address: String, port: int) -> Error:
	var client_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var err: Error = client_peer.create_client(address, port)
	if err != OK:
		return err
	multiplayer.multiplayer_peer = client_peer
	change_to_game_scene()
	return OK

func handle_nat_connection(address: String, port: int) -> Error:
	var error: Error = await connect_to_server(address, port)
	if error != OK and !is_host:
		print("NAT failed! Using relay...")
		Noray.connect_relay(external_oid)
	return error

func handle_relay_connection(address: String, port: int) -> Error:
	return await connect_to_server(address, port)

func connect_to_server(address: String, port: int) -> Error:
	var err: Error = OK

	if !is_host:
		var udp: PacketPeerUDP = PacketPeerUDP.new()
		udp.bind(Noray.local_port)
		udp.set_host_address(address, port)
		err = await PacketHandshake.over_packet_peer(udp)
		udp.close()

		if err != OK:
			if err != ERR_BUSY:
				print("Handshake failed with error: ", error_string(err))
				return err
		else:
			print("Handshake success!")
		return create_client(address, port)
	else:
		err = await PacketHandshake.over_enet(multiplayer.multiplayer_peer.host, address, port)
	return err

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
	if is_instance_valid(players_spawn_node):



		var gc_to_remove: GameCharacter = players_spawn_node.get_node_or_null("Player%d" % id)
		if gc_to_remove:
			gc_to_remove.queue_free()


func setup_upnp_port(upnp: UPNP, port: int) -> String:
	print("Discover ", port)
	var discover_error: int = upnp.discover()
	if discover_error != UPNP.UPNP_RESULT_SUCCESS:
		match discover_error:
			24:
				return "Offline?"
			27:
				return "No devices found!"
		return "UPNP Discovery Error! Error code: %d" % discover_error
	var device_count: int = upnp.get_device_count()
	print("Devices: ", device_count)

	for i: int in device_count:
		var device: UPNPDevice = upnp.get_device(i)
		print(device)
	if !upnp.get_gateway() or !upnp.get_gateway().is_valid_gateway():
		return "Invalid gateway!"
	var map_err: Error = upnp.add_port_mapping(port)
	if map_err != UPNP.UPNP_RESULT_SUCCESS:
		return "UPNP Port Mapping Failed! Error code: %d" % map_err
	return ""

func setup_upnp(port: int, output_label: Label) -> void:
	var upnp: UPNP = UPNP.new()
	var error_message: String = setup_upnp_port(upnp, port)
	if error_message.is_empty():
		output_label.modulate = Color.BLACK
		output_label.text = "Address: " + upnp.query_external_address()
	else:
		output_label.text = error_message
		output_label.modulate = Color.RED
