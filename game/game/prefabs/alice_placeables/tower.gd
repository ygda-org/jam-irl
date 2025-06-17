extends StaticBody2D

@onready var bob = get_parent().get_parent().get_node("Bob")
@onready var game = get_parent().get_parent().get_parent()

var bob_in_range = false


func attack():
	game.create_projectile(FiringPosition.position)

func _on_range_body_entered(body: Node2D) -> void:
	if body.name == "Bob":
		bob_in_range = true
	$Cooldown.start()


func _on_range_body_exited(body: Node2D) -> void:
	if body.name == "Bob":
		bob_in_range = false


func _on_cooldown_timeout() -> void:
	pass # Replace with function body.
