extends CanvasLayer

func _ready() -> void:
	if not NetworkInfo.is_server():
		%DebugClientListLabel.queue_free()

func get_debug_label() -> Label:
	return %DebugLabel

func get_debug_client_list_label() -> Label:
	return %DebugClientListLabel
