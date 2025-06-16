extends Node2D

@export var input_vector = Vector2(0,0)

@onready var main_parent = find_parent("SyncGame")

func _ready() -> void:
	if NetworkInfo.is_server():
		GlobalLog.server_log("Server Player Manager Spawned-Error?")
	else:
		GlobalLog.client_log("Client Player Manager Spawned")

func _process(delta: float) -> void:
	input_vector = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	$Label.text = "INPUT_VECTOR: " + str(input_vector)
	main_parent.rpc("send_client_input", input_vector)
	if Input.is_action_just_pressed("ui_left"):
		MusicManager.clear_all_audio()
		MusicManager.create_audio(SoundEffectSettings.SOUND_EFFECT_LABEL.LOBBYJAM_A)
	if Input.is_action_just_pressed("ui_right"):
		MusicManager.clear_all_audio()
		MusicManager.create_audio(SoundEffectSettings.SOUND_EFFECT_LABEL.LOBBYJAM_B)
