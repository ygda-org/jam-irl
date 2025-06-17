extends Node2D

@onready var address: TextEdit = $"Debug Menu/Address"
@onready var code: TextEdit = $"Debug Menu/Code"
@onready var port: TextEdit = $"Debug Menu/Port"

@onready var joinCode: TextEdit = $Control/Code

func _ready() -> void:
	var args: = OS.get_cmdline_args()
	
	if args.has("--server"): # If it's a server, begin
		NetworkManager.state = NetworkManager.State.Server
		if args.has("--port"):
			NetworkManager.port = int(args[args.find("--port") + 1])
		
		if args.has("--code"):
			NetworkManager.code = args[args.find("--code") + 1]
		
		SceneSwitcher.goto_scene("res://SYNC TESTING/sync_game.tscn")
	else: # If it's a user, request an ID
		NetworkManager.state = NetworkManager.State.Client
		
		if NetworkManager.user_id != "none": # If the client already has a userid, don't request a new one
			return
		
		var json = await HttpWrapper.request(%AwaitableHTTP, "/user/", HTTPClient.METHOD_POST)
		if json: 
			NetworkManager.user_id = json["userId"]
			GlobalLog.client_log("Retrieved userID %s from matchmaking server." % NetworkManager.user_id)
		else:
			GlobalLog.client_log("Failed to get userID from matchmaking server.")

func _on_button_pressed() -> void:
	NetworkManager.state = NetworkManager.State.Client
	NetworkManager.address_with_port = address.text + ":" + port.text
	NetworkManager.code = code.text
	SceneSwitcher.goto_scene("res://SYNC TESTING/sync_game.tscn")

func _on_debug_server_pressed() -> void:
	NetworkManager.state = NetworkManager.State.Server
	SceneSwitcher.goto_scene("res://SYNC TESTING/sync_game.tscn")

func _on_create_match_pressed() -> void:
	var res = await HttpWrapper.request(%AwaitableHTTP, "/match/create", HTTPClient.METHOD_POST, {
		"userId": NetworkManager.user_id,
	})
	if res:
		res = res as Dictionary
		var code = res["match"]["code"]
		var gsiUrl = res["match"]["gsiUrl"]
		GlobalLog.client_log("Created match with code %s and GSI URL %s" % [code, gsiUrl])
	else:
		GlobalLog.client_log("Failed to create match.")

func _on_join_match_pressed() -> void:
	GlobalLog.client_log("Joining match...")
	var res = await HttpWrapper.request(%AwaitableHTTP, "/match/join", HTTPClient.METHOD_POST, {
		"userId": NetworkManager.user_id,
		"code": joinCode.text
	})
	if res:
		res = res as Dictionary
		var gsiUrl = res["match"]["gsiUrl"]
		GlobalLog.client_log("Joined match with GSI URL %s" % gsiUrl)
	else:
		GlobalLog.client_log("Failed to join match.")
