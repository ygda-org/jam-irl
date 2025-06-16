extends Node2D

@export var input_vector = Vector2(0,0)

func _process(delta: float) -> void:
	input_vector = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
