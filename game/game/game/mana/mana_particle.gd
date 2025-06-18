extends Node2D

var velocity
@onready var bob = get_node("/root/Game/Arena/Bob")


const deceleration = 0.5
const speed = 100

var spreading = true

func _ready():
	$SpreadTime.start()

func _process(delta):
	position += velocity * delta
	if abs(position.x - bob.position.x) < 50 and abs(position.y - bob.position.y) < 50:
		collect()
	if spreading:
		velocity.x = velocity.x - deceleration * (1 if velocity.x > 0 else -1)
		velocity.y = velocity.y - deceleration * (1 if velocity.y > 0 else -1)
		if (abs(velocity.x) <= deceleration):
			velocity.x = 0
		if (abs(velocity.y) <= deceleration):
			velocity.y = 0
	else:
		velocity = position.direction_to(bob.position) * speed


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Bob":
		collect()


func _on_spread_time_timeout() -> void:
	spreading = false

func collect():
	bob.update_mana(1)
	queue_free()
