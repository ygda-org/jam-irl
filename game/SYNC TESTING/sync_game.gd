extends Node2D

const time_till_timout: float = 3.0
const ServerDataObject = preload("res://game/server_data.gd")
const TEST_PLAYER_MANAGER = preload("res://test_player/test_player_manager.tscn")

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var server_data: ServerData = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if NetworkInfo.is_server():
		server_data = ServerDataObject.new()
		connect_server()
	else:
		connect_client()

## Server functions
func connect_server():
	var res: Error = peer.create_server(NetworkInfo.port)
	if res != OK:
		GlobalLog.server_log("Failed to start game instance on port " + str(NetworkInfo.port))
		get_tree().quit(1)
		return 
	else:
		GlobalLog.server_log("Started game instance on port " + str(NetworkInfo.port))

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_new_player)
	multiplayer.peer_disconnected.connect(_disconnect_player)
	
	%LobbyUI.get_debug_label().text = "Game Instance running on port " + str(NetworkInfo.port)

func _new_player(id: int):
	if not server_data.add_peer(id): # Server is full, 2 players are already present
		peer.disconnect_peer(id, true)
		GlobalLog.server_log("Client tried connected, server was full.")
		return
	
	GlobalLog.server_log("New player joined with id of " + str(id)  + ". Asking for room code.")
	rpc_id(id, "request_room_code")
	await get_tree().create_timer(3).timeout
	
	if server_data.peer_exists(id) and not server_data.is_verified(id):
		# Client took to long to give room code, kick them
		# An attacker could spam timeout a room and not let anybody in.
		GlobalLog.server_log("Peer with id of " + str(id) + " timed out. Kicking them.")
		server_data.remove_peer(id)
		peer.disconnect_peer(id)
	
func _disconnect_player(id: int):
	GlobalLog.server_log("Player " + str(id) + " disconnected.")

func update_debug_client_list() -> void:
	%LobbyUI.get_debug_client_list_label().text = str(server_data.id_to_client_data.keys())

@rpc("any_peer")
func send_room_code(code: String):
	if not NetworkInfo.is_server():
		return
	
	var sender_id: int = multiplayer.get_remote_sender_id()
	if server_data.is_verified(sender_id):
		GlobalLog.server_log("Verified client tried verifying again.")
		return
	
	if NetworkInfo.code == code:
		server_data.verify_peer(sender_id)
		GlobalLog.server_log("Successfully verified peer with id of " + str(sender_id))
		rpc_id(sender_id, "verify_verification")
	else:
		GlobalLog.server_log("Kicking out peer with id of " + str(sender_id) + " for invalid code.")
		server_data.remove_peer(sender_id)
		peer.disconnect_peer(sender_id)
	
	update_debug_client_list()

@rpc("any_peer")
func debug_end_game():
	if not NetworkInfo.is_server():
		return
	
	GlobalLog.server_log("Ending game instance! Goodbye!")
	get_tree().quit(0)

###

## Client Functions
func connect_client():
	var address: String = NetworkInfo.get_address_with_protocol()
	var res: Error = peer.create_client(address)
	if res != OK:
		SceneSwitcher.start_menu_with_error("Failed to connect client at address " + address)
		return
	else:
		GlobalLog.client_log("Successfully connected to address " + address)
	
	multiplayer.server_disconnected.connect(_disconnected)
	multiplayer.connection_failed.connect(_disconnected) # TODO: Use another more descriptive _disconnected for connection_failed.
	multiplayer.multiplayer_peer = peer
	
	%LobbyUI.get_debug_label().text = "Connected to address " + address
	var manager = TEST_PLAYER_MANAGER.instantiate()
	call_deferred("add_child",manager)

func _disconnected() -> void:
	SceneSwitcher.start_menu_with_error("Disconnected from server.")

@rpc("any_peer")
func send_client_input(input : Variant):
	$Label.text = str(input)
	$SyncBob.interpret_input(input)

@rpc("authority")
func request_room_code():
	if NetworkInfo.is_server():
		return
	
	rpc("send_room_code", NetworkInfo.code)

@rpc("authority")
func verify_verification() -> void:
	%LobbyUI.get_debug_label().text = "Verified at address " + NetworkInfo.get_address_with_protocol()

###


func _on_debug_end_game_pressed() -> void:
	if NetworkInfo.is_server():
		GlobalLog.server_log("Ending game instance! Goodbye!")
		get_tree().quit(0)
	else:
		rpc("debug_end_game")
		
