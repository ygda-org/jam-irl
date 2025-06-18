@tool
extends TextureRect

@export var parentSize: bool = false

func _process(delta: float) -> void:
	if parentSize:
		size = get_parent().get_size()
	else: 
		size = get_size()
	material.set_shader_parameter("node_size", size)
