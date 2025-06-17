extends Node2D


func _ready():
	_update_debug_label()

	if NetworkManager.is_alice():
		add_child(load("res://game/game/alice_controller.tscn").instantiate())
	
func _update_debug_label():
	%DebugLabel.text = "Role: "
	if NetworkManager.is_alice():
		%DebugLabel.text += "Alice"
	elif NetworkManager.is_bob():
		%DebugLabel.text += "Bob"
	elif NetworkManager.is_server():
		%DebugLabel.text += "Server"
	if NetworkManager.verified:
		%DebugLabel.text += " | Verified"
	
	%DebugLabel.text += " | URL: " + NetworkManager.get_address_with_protocol() + " [" + str(NetworkManager.code) + "]"


func _on_debug_end_game_pressed() -> void:
	if NetworkManager.is_server():
		debug_end_game()
		get_tree().quit(0)
	else:
		rpc("debug_end_game")
		# SceneSwitcher.goto_start()

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
