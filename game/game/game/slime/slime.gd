extends CharacterBody2D

@export var speed: float = 100.0
@export var max_health: int = 100
@export var health: int = max_health
@export var damage: int = 10
@export var target: Vector2 = Vector2.ZERO


func _ready() -> void:
	# target = bob
	pass

func _process(delta: float) -> void:
	pass
