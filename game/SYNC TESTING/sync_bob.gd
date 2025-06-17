extends CharacterBody2D

var direction = Vector2(0, 0)
const acceleration = 10
const deceleration = 20
const max_speed = 150

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	move_handler()
	move_and_slide()

func interpret_input(input : Variant):
	if input is String:
		if input == "attack":
			attack()
	elif input is Vector2:
		direction = input

func move_handler():
	if (direction.x * velocity.x < 0):
		velocity.x += direction.x * deceleration
	if (direction.y * velocity.y < 0):
		velocity.y += direction.y * deceleration
	velocity += acceleration * direction
	if direction.x == 0:
		if (abs(velocity.x) < deceleration):
			velocity.x = 0
		else:
			velocity.x -= deceleration * (1 if velocity.x > 0 else -1)
	if direction.y == 0:
		if (abs(velocity.y) < deceleration):
			velocity.y = 0
		else:
			velocity.y -= deceleration * (1 if velocity.y > 0 else -1)

func attack():
	pass
