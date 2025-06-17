extends Node2D

var health = 100

func hit(dmg: int):
	var old = health
	health -= hit
	if health <= 0:
		$Anim.play("turbo_dead")
	elif health <= health/4:
		$Anim.play("turbo_cancer")
	elif health <= health/2:
		$Anim.play("slight_hurt")
	else:
		$Anim.play("healthy")
