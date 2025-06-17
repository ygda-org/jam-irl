extends CanvasLayer

func _ready() -> void:
	if not NetworkManager.is_server():
		%DebugClientListLabel.queue_free()

func get_debug_label() -> Label:
	return %DebugLabel

func get_debug_client_list_label() -> Label:
	return %DebugClientListLabel


func _on_alice_start_pressed() -> void:
	get_parent().rpc_id(1, "start_game", NetworkManager.Role.Alice)
	
func _on_bob_start_pressed() -> void:
	get_parent().rpc_id(1, "start_game", NetworkManager.Role.Bob)
