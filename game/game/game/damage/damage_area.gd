extends Area2D

@export var damage: int = 20
@export var time_till_damage_again: float = 5

@onready var damage_timer: Timer = $DamageTimer
var can_damage: bool = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Damageable") && can_damage:
		body.damage(damage)
		can_damage = false
		damage_timer.start(time_till_damage_again)


func _on_damage_timer_timeout() -> void:
	can_damage = true
