extends Node2D

@onready var target = get_parent()
const margin = 20

func _process(delta):
	target.z_index = Vector2i((target.position - Vector2(margin, margin)) / 50).y
