extends Node2D


@onready var camera_2d: Camera2D = $Camera2D

var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match NetworkInfo.state:
		NetworkInfo.State.Server:
			peer.create_server(NetworkInfo.port)
			multiplayer.multiplayer_peer = peer
			multiplayer.peer_connected.connect(_new_player)
			multiplayer.peer_disconnected.connect(_disconnect_player)
			return
		NetworkInfo.State.Alice:
			peer.create_client(NetworkInfo.get_address())
			multiplayer.multiplayer_peer = peer
			return
		NetworkInfo.State.Bob:
			peer.create_client(NetworkInfo.get_address())
			multiplayer.multiplayer_peer = peer
			return
			
func _new_player(id: int):
	print("New player joined with id of " + str(id))
	
func _disconnect_player(id: int):
	print("Player " + str(id) + " disconnected.")
