extends Node2D

@export var sound_effect_settings : Array[SoundEffectSettings]

var sound_effect_dict : Dictionary[SoundEffectSettings.SOUND_EFFECT_LABEL, SoundEffectSettings]

var general_music_playing = false

func _ready() -> void:
	for setting : SoundEffectSettings in sound_effect_settings:
		sound_effect_dict[setting.label] = setting

func _process(delta: float) -> void:
	var current_scene = get_parent().get_child(6)
	if current_scene.name == "StartScreen" and not general_music_playing:
		general_music_playing = true
		create_audio(SoundEffectSettings.SOUND_EFFECT_LABEL.BATTLE_A)

func _on_audio_finished(source : AudioStreamPlayer):
	if int(source.name) < 4:
		GlobalLog.log("YES THANK GOD")
		general_music_playing = false

@rpc("any_peer")
func create_2d_audio(position : Vector2, type : SoundEffectSettings.SOUND_EFFECT_LABEL):
	var audioplayer : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	add_child(audioplayer)
	audioplayer.position = position
	var sound_effect_setting = sound_effect_dict[type]
	audioplayer.stream = sound_effect_setting.stream
	audioplayer.volume_db = sound_effect_setting.volume
	audioplayer.pitch_scale = sound_effect_setting.pitch
	audioplayer.finished.connect(audioplayer.queue_free)
	audioplayer.name = str(sound_effect_setting.label)
	audioplayer.play()
	if NetworkManager.is_server():
		GlobalLog.server_log("Playing: " + str(sound_effect_setting.label))
	else:
		GlobalLog.client_log("Playing: " + str(sound_effect_setting.label))

@rpc("any_peer")
func create_audio(type : SoundEffectSettings.SOUND_EFFECT_LABEL):
	var audioplayer : AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audioplayer)
	var sound_effect_setting = sound_effect_dict[type]
	audioplayer.stream = sound_effect_setting.stream
	audioplayer.volume_db = sound_effect_setting.volume
	audioplayer.pitch_scale = sound_effect_setting.pitch
	audioplayer.finished.connect(audioplayer.queue_free)
	audioplayer.name = str(sound_effect_setting.label)
	audioplayer.finished.connect(_on_audio_finished.bind(audioplayer))
	audioplayer.play()
	if NetworkManager.is_server():
		GlobalLog.server_log("Playing: " + str(sound_effect_setting.label))
	else:
		GlobalLog.client_log("Playing: " + str(sound_effect_setting.label))

func clear_all_audio():
	for child in get_children():
		child.queue_free()
