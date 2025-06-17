extends CharacterBody2D

const SPEED: int = 10000
signal died

@export var health: int = 100

var input: Vector2 = Vector2(0, 0)

func _ready() -> void:
	if not NetworkManager.is_server(): # Disable collisions if it's a client.
		%CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	if not NetworkManager.is_server():
		return
		
	velocity = delta * SPEED * input
	
	move_and_slide()

func damage(damage: int):
	if not NetworkManager.is_server(): return
	
	health -= damage
	
	if health <= 0:
		GlobalLog.server_log("Bob has died!")
		died.emit()
