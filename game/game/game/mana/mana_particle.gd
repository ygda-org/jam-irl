extends Node2D

var velocity

const deceleration = 0.5

func _process(delta):
	position += velocity * delta
	velocity.x = velocity.x - deceleration * (1 if velocity.x > 0 else -1)
	velocity.y = velocity.y - deceleration * (1 if velocity.y > 0 else -1)
	if (abs(velocity.x) <= deceleration):
		velocity.x = 0
	if (abs(velocity.y) <= deceleration):
		velocity.y = 0
