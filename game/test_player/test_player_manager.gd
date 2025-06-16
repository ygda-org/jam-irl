extends Node2D

@export var input_vector = Vector2(0,0)

func _ready() -> void:
	if NetworkInfo.is_server():
		GlobalLog.server_log("Server Player Manager Spawned-Error?")
	else:
		GlobalLog.client_log("Client Player Manager Spawned")

func _process(delta: float) -> void:
	input_vector = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	$Label.text = "INPUT_VECTOR: " + str(input_vector)
