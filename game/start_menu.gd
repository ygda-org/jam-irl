extends Node2D

@onready var address: TextEdit = $Address
@onready var port: TextEdit = $Port
@onready var code: TextEdit = $Code

func _ready() -> void:
	var args: = OS.get_cmdline_args()
	
	if args.has("--server"): # If it's a server, begin
		if args.has("--port"):
			NetworkInfo.port = int(args[args.find("--port") + 1])
		
		if args.has("--code"):
			NetworkInfo.code = args[args.find("--code") + 1]
		
		SceneSwitcher.goto_scene("res://game/game.tscn")
	else: # If it's a user, request an ID
		var headers = ["Content-Type: applications/json"]
		var user_request_res = await %AwaitableHTTP.async_request(NetworkInfo.match_making_address + "/user/", headers, HTTPClient.METHOD_POST)
		if user_request_res.success() and user_request_res.status_ok():
			var json = user_request_res.body_as_json()
			NetworkInfo.user_id = json["userId"]
			GlobalLog.client_log("Got userID %s from matchmaking server." % NetworkInfo.user_id)
		else:
			GlobalLog.client_log("Failed to get userID from matchmaking server.")


func _on_button_pressed() -> void:
	NetworkInfo.state = NetworkInfo.State.Client
	NetworkInfo.address = address.text
	NetworkInfo.port = int(port.text)
	NetworkInfo.code = code.text
	SceneSwitcher.goto_scene("res://game/game.tscn")

func _on_debug_server_pressed() -> void:
	
	SceneSwitcher.goto_scene("res://game/game.tscn")
	
