@tool
extends TextureRect

func _process(delta: float) -> void:
	material.set_shader_parameter("node_size", get_size())
