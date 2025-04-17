const SERVER_PORT = 7777

func start_server() -> void:
	var peer = ENetMultiplayerPeer.new()

	# The container port in the Hathora Deployment Settings should match SERVER_PORT
	var error = peer.create_server(SERVER_PORT, MAX_CONNECTIONS)
	if error:
		return
		multiplayer.multiplayer_peer = peer
