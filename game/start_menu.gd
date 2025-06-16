extends Node2D

@onready var address: TextEdit = $"Debug Menu/Address"
@onready var code: TextEdit = $"Debug Menu/Code"
@onready var port: TextEdit = $"Debug Menu/Port"

@onready var joinCode: TextEdit = $Control/Code

func _ready() -> void:
	var args: = OS.get_cmdline_args()
	
	if args.has("--server"): # If it's a server, begin
		NetworkInfo.state = NetworkInfo.State.Server
		if args.has("--port"):
			NetworkInfo.port = int(args[args.find("--port") + 1])
		
		if args.has("--code"):
			NetworkInfo.code = args[args.find("--code") + 1]
		
		SceneSwitcher.goto_scene("res://game/game.tscn")
	else: # If it's a user, request an ID
		NetworkInfo.state = NetworkInfo.State.Client
		var json: Dictionary = await HttpWrapper.request(%AwaitableHTTP, "/user/", HTTPClient.METHOD_POST)
		if json: 
			NetworkInfo.user_id = json["userId"]
			GlobalLog.client_log("Retrieved userID %s from matchmaking server." % NetworkInfo.user_id)
		else:
			GlobalLog.client_log("Failed to get userID from matchmaking server.")

func _on_button_pressed() -> void:
	NetworkInfo.state = NetworkInfo.State.Client
	NetworkInfo.address = address.text
	NetworkInfo.port = int(port.text)
	NetworkInfo.code = code.text
	SceneSwitcher.goto_scene("res://game/game.tscn")

func _on_debug_server_pressed() -> void:
	NetworkInfo.state = NetworkInfo.State.Server
	SceneSwitcher.goto_scene("res://game/game.tscn")

func _on_create_match_pressed() -> void:
	var res: Dictionary = await HttpWrapper.request(%AwaitableHTTP, "/match/create", HTTPClient.METHOD_POST, {
		"userId": NetworkInfo.user_id,
	})
	GlobalLog.client_log(JSON.stringify(res))
	var code = res["match"]["code"]
	var gsiUrl = res["match"]["gsiUrl"]
	GlobalLog.client_log("Created match with code %s and GSI URL %s" % [code, gsiUrl])

func _on_join_match_pressed() -> void:
	GlobalLog.client_log("Joining match...")
	pass
