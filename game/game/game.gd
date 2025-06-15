extends Node2D


@onready var camera_2d: Camera2D = $Camera2D

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if NetworkInfo.is_server():
		connect_server()
	else:
		connect_client()


func connect_server():
	var res: Error = peer.create_server(NetworkInfo.port)
	if res != OK:
		print("Failed to start game instance on port " + str(NetworkInfo.port))
		get_tree().quit(1)
		return 
	else:
		print("Started game instance on port " + str(NetworkInfo.port))

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_new_player)
	multiplayer.peer_disconnected.connect(_disconnect_player)

func connect_client():
	var address: String = NetworkInfo.get_address_with_port()
	var res: Error =peer.create_client(address)
	if res != OK:
		print("Failed to connect client to address " + address)
	else:
		print("Successfully connected to address " + address)
	
	multiplayer.multiplayer_peer = peer


func _new_player(id: int):
	print("New player joined with id of " + str(id))
	
func _disconnect_player(id: int):
	print("Player " + str(id) + " disconnected.")
