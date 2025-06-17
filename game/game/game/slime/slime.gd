extends CharacterBody2D

@export var speed: float = 100.0
@export var max_health: int = 100
@export var health: int = max_health
@export var damage: int = 10
@export var target: Node2D

@onready var board = get_parent().get_node("GameBoard")

func _ready() -> void:
	target = get_parent().get_node("Bob")
	if target == null:
		push_error("Bob not found in scene!")

func _physics_process(delta: float) -> void:
	var direction = (target.position - position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# Optional: Add some debug visualization
	queue_redraw()

func _draw() -> void:
	if target != null:
		# Draw a line to the target
		draw_line(Vector2.ZERO, to_local(target.position), Color.RED, 2.0)
