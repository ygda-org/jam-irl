extends Node2D

var input: Vector2 = Vector2(0, 0)	

func _on_input_tick_timeout() -> void:
	if not NetworkManager.is_bob():
		return
	var old_input = input
	input = Input.get_vector("Left", "Right", "Up", "Down")
	
	if not old_input == input:
		rpc_id(1, "send_input", input)


@rpc("any_peer")
func send_input(input: Vector2):
	if not NetworkManager.is_server():
		return
	
	get_parent().update_bob_input(input)
