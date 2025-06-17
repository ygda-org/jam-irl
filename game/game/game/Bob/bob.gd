extends CharacterBody2D

const SPEED: int = 300

var input: Vector2 = Vector2(0, 0)

func _ready() -> void:
	if not NetworkManager.is_server(): # Disable collisions if it's a client.
		%CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	if not NetworkManager.is_server():
		return
	
	position += delta * SPEED * input
