extends CharacterBody2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	move_and_slide()

func interpret_input(input : Vector2):
	velocity = input * 100
