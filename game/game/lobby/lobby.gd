extends Node2D

const time_till_timout: float = 3.0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if NetworkManager.is_server():
		if NetworkManager.connect_server():
			%LobbyUI.get_debug_label().text = "Game Instance running on port " + str(NetworkManager.port)
	else:
		if NetworkManager.connect_client():
			%LobbyUI.get_debug_label().text = "Connected to address " + NetworkManager.get_address_with_protocol()

func update_debug_client_list() -> void:
	%LobbyUI.get_debug_client_list_label().text = str(NetworkManager.server_data.id_to_client_data.keys())

func update_debug_verification() -> void:
	%LobbyUI.get_debug_label().text = "Verified at address " + NetworkManager.get_address_with_protocol()

@rpc("any_peer")
func debug_end_game():
	if not NetworkManager.is_server():
		return

	GlobalLog.server_log("Ending game instance! Goodbye!")
	
	var res = await HttpWrapper.request(%AwaitableHTTP, "/match/end", HTTPClient.METHOD_POST, {
		"matchId": NetworkManager.match_id,
		"code": NetworkManager.code
	})
	
	if res:
		GlobalLog.server_log("Successfully told matchmaking server that game is ending.")
	else:
		GlobalLog.server_log("Failed to tell matchmaking server game ended.")
	
	get_tree().quit(0)

@rpc("any_peer")
func start_game(role: NetworkManager.Role):
	GlobalLog.log("Starting game with role " + str(role))
	if not NetworkManager.is_server():
		return
	
	if NetworkManager.server_data.id_to_client_data.keys().size() != 2:
		GlobalLog.server_log("Client tried to start the game when 2 clients haven't connected yet!")
		return
	
	NetworkManager.server_data.update_client_ids(multiplayer.get_remote_sender_id(), role)
	rpc_id(NetworkManager.server_data.alice_id, "send_role_and_start", NetworkManager.Role.Alice)
	rpc_id(NetworkManager.server_data.bob_id, "send_role_and_start", NetworkManager.Role.Bob)
	%LobbyUI.queue_free()
	GlobalLog.server_log("Starting game!")
	SceneSwitcher.goto_game()

###

@rpc("authority")
func send_role_and_start(role: NetworkManager.Role):
	NetworkManager.role = role
	SceneSwitcher.goto_game()
###


func _on_debug_end_game_pressed() -> void:
	if NetworkManager.is_server():
		debug_end_game()
		get_tree().quit(0)
	else:
		rpc("debug_end_game")
		
