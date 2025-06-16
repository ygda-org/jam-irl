extends Resource
class_name SoundEffectSettings

enum SOUND_EFFECT_LABEL{
	LOBBYJAM_A,
	LOBBYJAM_B
}

@export var label : SOUND_EFFECT_LABEL
@export var stream : AudioStream
@export_range(-40,24) var volume : float = 1.0
@export_range(0.01, 4.0) var pitch : float = 1.0
