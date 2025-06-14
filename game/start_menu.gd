extends Node2D

@onready var address: TextEdit = $Address
@onready var port: TextEdit = $Port
@onready var room_id: TextEdit = $RoomID

func _ready() -> void:
	var args: = OS.get_cmdline_args()
	
	if args.has("--port"):
		NetworkInfo.port = int(args[args.find("--port") + 1])
	
	if args.has("--server"):
		SceneSwitcher.goto_scene("res://game/game.tscn")
	
		

func _on_button_pressed() -> void:
	NetworkInfo.state = NetworkInfo.State.Bob
	NetworkInfo.address = address.text
	NetworkInfo.port = int(port.text)


func _on_debug_server_pressed() -> void:
	SceneSwitcher.goto_scene("res://game/game.tscn")
