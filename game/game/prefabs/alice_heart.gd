extends Node2D

var health = 100
const max_health = 100

func _ready():
	hit(99)

func hit(dmg: int):
	health -= dmg
	if health <= 0:
		$Anim.play("turbo_dead")
	elif health <= max_health/4:
		$Anim.play("turbo_cancer")
	elif health <= max_health/2:
		$Anim.play("slight_hurt")
	else:
		$Anim.play("healthy")
