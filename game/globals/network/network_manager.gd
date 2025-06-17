extends Node

enum State {
	Client,
	Server
}

enum Role {
	None,
	Alice,
	Bob
}

## Match making server info:
@export var match_making_address = "http://localhost:8000"
##

@export var state: State = State.Server
@export var role: Role = Role.None

## Game instance info:
@export var port: int = 9999 # 9999 is default game instance port, docker container binds it to port 10000-19999 on host machine
@export var code: String = "default"
##

## Client info:
@export var user_id: String = "none"
@export var match_id: String = ""
@export var address_with_port: String = "ws://localhost:9999"
@export var verified: bool = false
##

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
var server_data: ServerData = null
const ServerDataObject = preload("res://globals/network/server_data.gd")

func get_address_with_protocol(tls: bool = false) -> String:
	return address_with_port

func is_server() -> bool:
	return state == State.Server

func is_client() -> bool:
	return state == State.Client

func is_alice() -> bool:
	return role == Role.Alice

func is_bob() -> bool:
	return role == Role.Bob

### Server Connection
func connect_server():
	server_data = ServerDataObject.new()
	var res: Error = peer.create_server(NetworkManager.port)
	if res != OK:
		GlobalLog.server_log("Failed to start game instance on port " + str(NetworkManager.port))
		get_tree().quit(1)
		return false
	else:
		GlobalLog.server_log("Started game instance on port " + str(NetworkManager.port))

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_handle_player_connect)
	multiplayer.peer_disconnected.connect(_handle_player_disconnect)
	return true

func _handle_player_connect(id: int):
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
	
func _handle_player_disconnect(id: int):
	GlobalLog.server_log("Player " + str(id) + " disconnected.")

## Room Code Handshake
# player connect -> rpc request_room_code on client -> send_room_code
@rpc("authority")
func request_room_code():
	if NetworkManager.is_server():
		return
	
	rpc("verify_room_code", NetworkManager.code) # client send code to server via rpc
	
@rpc("any_peer")
func verify_room_code(client_code: String):
	if NetworkManager.is_client():
		return
	
	var sender_id: int = multiplayer.get_remote_sender_id()
	if server_data.is_verified(sender_id):
		GlobalLog.server_log("Verified client tried verifying again.")
		return
	
	if NetworkManager.code == client_code:
		server_data.verify_peer(sender_id)
		GlobalLog.server_log("Successfully verified peer with id of " + str(sender_id))
		rpc_id(sender_id, "code_verified")
	else:
		GlobalLog.server_log("Kicking out peer with id of " + str(sender_id) + " for invalid code.")
		server_data.remove_peer(sender_id)
		peer.disconnect_peer(sender_id)

@rpc("authority")
func code_verified() -> void:
	GlobalLog.client_log("Code verified") # TODO: emit a signal
	verified = true
	
### Client Functions
func connect_client():
	var address: String = NetworkManager.get_address_with_protocol()
	var res: Error = peer.create_client(address)
	if res != OK:
		SceneSwitcher.start_menu_with_error("Failed to connect client at address " + address)
		return false
	else:
		GlobalLog.client_log("Successfully connected to address " + address)
	
	multiplayer.server_disconnected.connect(_handle_client_side_disconnected)
	multiplayer.connection_failed.connect(_handle_client_side_disconnected) # TODO: Use another more descriptive _disconnected for connection_failed.
	multiplayer.multiplayer_peer = peer
	
	return true

func _handle_client_side_disconnected() -> void:
	GlobalLog.client_log("Disconnected from server.")
