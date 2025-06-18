extends Node2D

@onready var address: TextEdit = $"Debug Menu/Address"
@onready var code: TextEdit = $"Debug Menu/Code"
@onready var port: TextEdit = $"Debug Menu/Port"

@onready var joinCode: TextEdit = $JoinMenu/Code

func _ready() -> void:
	var args: = OS.get_cmdline_args()
	_parse_args(args)
	
	if NetworkManager.is_server():
		SceneSwitcher.goto_lobby()
	else: # If it's a user, request an ID
		if NetworkManager.user_id != "none": # If the client already has a userid, don't request a new one
			return
		
		var json = await HttpWrapper.request(%AwaitableHTTP, "/user/", HTTPClient.METHOD_POST)
		if json:
			json = json as Dictionary
			NetworkManager.user_id = json["userId"]
			GlobalLog.client_log("Retrieved userID %s from matchmaking server." % NetworkManager.user_id)
		else:
			GlobalLog.client_log("Failed to get userID from matchmaking server.")

func _parse_args(args: PackedStringArray) -> void:
	if args.has("--server"):
		NetworkManager.state = NetworkManager.State.Server
		if args.has("--port"):
			NetworkManager.port = int(args[args.find("--port") + 1])
		if args.has("--code"):
			NetworkManager.code = args[args.find("--code") + 1]
		if args.has("--match-id"):
			NetworkManager.match_id = args[args.find("--match-id") + 1]
	else:
		NetworkManager.state = NetworkManager.State.Client
		if args.has("--user-id"):
			NetworkManager.user_id = args[args.find("--user-id") + 1]
	
	# if args.has("--mute"):
	# 	Settings.mute = true

func _on_debug_client_pressed() -> void:
	_to_lobby(NetworkManager.State.Client, address.text + ":" + port.text, code.text)

func _on_debug_server_pressed() -> void:
	NetworkManager.state = NetworkManager.State.Server
	SceneSwitcher.goto_lobby()

func _to_lobby(state: NetworkManager.State, url: String, code: String) -> void:
	NetworkManager.state = state
	NetworkManager.address_with_port = url
	NetworkManager.code = code
	SceneSwitcher.goto_lobby()

func _on_create_match_pressed() -> void:
	GlobalLog.client_log("Sent match create request to MS. Waiting...")
	$CreateMenu.get_node("Label").text = "Creating match..."
	var res = await HttpWrapper.request(%AwaitableHTTP, "/match/create", HTTPClient.METHOD_POST, {
		"userId": NetworkManager.user_id,
	})
	if res:
		res = res as Dictionary
		var code = res["match"]["code"]
		var gsiUrl = res["match"]["gsiUrl"]
		GlobalLog.client_log("Created match with code %s and GSI URL %s" % [code, gsiUrl])
		$CreateMenu.get_node("Label").text = "Match created!"
		_to_lobby(NetworkManager.State.Client, gsiUrl, code)
	else:
		$CreateMenu.get_node("Label").text = "Failed to create."
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
		_to_lobby(NetworkManager.State.Client, gsiUrl, joinCode.text)
	else:
		GlobalLog.client_log("Failed to join match.")


func _on_button_pressed() -> void:
	SceneSwitcher.goto_scene("res://game/start/tutorial.tscn")
