extends Node2D

@onready var bob = get_node("/root/Game/Arena/Bob")

@export var dragCoefficient = 100
@export var attractionRadius = 100
@export var attractionForce = 1000
@export var collectionRadius = 30
var velocity = Vector2.ZERO

func _process(delta):
	position += velocity * delta
	var dir = bob.position - position
	if dir.length() < collectionRadius:
		collect()

	if velocity.length() < dragCoefficient*delta:
		velocity = Vector2.ZERO
	else: 
		velocity -= velocity.normalized() * dragCoefficient * delta
	

	if dir.length() < attractionRadius:
		velocity += dir.normalized() * attractionForce * delta
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Bob":
		collect()

func collect():
	if NetworkManager.is_server():
		bob.update_mana(1)
	queue_free()
