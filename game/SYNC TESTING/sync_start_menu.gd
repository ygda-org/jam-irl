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
		
		SceneSwitcher.goto_scene("res://SYNC TESTING/sync_game.tscn")
	else: # If it's a user, request an ID
		%UserIDRequest.request_completed.connect(on_userid_request_completed)
		var headers = ["Content-Type: applications/json"]
		%UserIDRequest.request(NetworkInfo.match_making_address + "/user", headers, HTTPClient.METHOD_POST)

func on_userid_request_completed(result, response_code, headers, body) -> void:
	print(str(response_code))
	print(str(result))
	print(str(headers))
	print(str(body))
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		NetworkInfo.user_id = json["userID"]
		GlobalLog.client_log("Received user id from matchmaking server: " + NetworkInfo.user_id)
	else:
		GlobalLog.client_log("Failed to request for a userid from matchmaking server.")
		

func _on_button_pressed() -> void:
	NetworkInfo.state = NetworkInfo.State.Client
	NetworkInfo.address = address.text
	NetworkInfo.port = int(port.text)
	NetworkInfo.code = code.text
	SceneSwitcher.goto_scene("res://SYNC TESTING/sync_game.tscn")

func _on_debug_server_pressed() -> void:
	
	SceneSwitcher.goto_scene("res://SYNC TESTING/sync_game.tscn")
	
