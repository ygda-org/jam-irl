extends StaticBody2D

var health = 100
const max_health = 100
@onready var _alice = get_tree().root.get_node("Game").get_node("AliceController")

func _ready():
	pass


func health_check():
	if health <= 0:
		$Anim.play("turbo_dead")
	elif health <= max_health/4:
		$Anim.play("turbo_cancer")
	elif health <= max_health/2:
		$Anim.play("slight_hurt")
	else:
		$Anim.play("healthy")

func alice():
	if _alice == null:
		_alice = get_tree().root.get_node("Game").get_node("AliceController")
	return _alice

func _on_target_on_death() -> void:
	rpc("__on_target_on_death")
	__on_target_on_death()

@rpc("authority")
func __on_target_on_death():
	alice().dec_health(1)
	suicide()

func suicide():
	rpc("_suicide")
	_suicide()

@rpc("authority")
func _suicide():
	queue_free()

func _on_target_on_damage(damage: int) -> void:
	health = $Target.health
	health_check()
	GlobalLog.server_log(str(self) + " has taken " + str(damage) + " damage!")

func _to_string() -> String:
	return "HEART: " + str(global_position)
