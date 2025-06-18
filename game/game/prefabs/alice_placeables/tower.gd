extends StaticBody2D

@onready var bob = get_parent().get_parent().get_node("Bob")
@onready var game = get_parent().get_parent().get_parent()

var projectile = preload("res://game/game/GenericProjectile/ProjectileSettingResources/tower_shot.tres")

var bob_in_range = false

@rpc("any_peer")
func attack() -> void:
	game.summon_projectile($FiringPosition.global_position, $FiringPosition.global_position.direction_to(bob.position), projectile, self)

func _on_range_body_entered(body: Node2D) -> void:
	if body.name == "Bob":
		bob_in_range = true
	$Cooldown.start()


func _on_range_body_exited(body: Node2D) -> void:
	if body.name == "Bob":
		bob_in_range = false

func _on_cooldown_timeout() -> void:
	if bob_in_range:
		rpc("attack")
		attack()
		$Cooldown.start()


func _on_target_on_death() -> void:
	GlobalLog.server_log(str(self) + " has died!")
	spawn_mana()
	rpc("spawn_mana")
	suicide()

func suicide():
	rpc("_suicide")
	_suicide()

@rpc("authority")
func _suicide():
	queue_free()

func _on_target_on_damage(damage: int) -> void:
	GlobalLog.server_log(str(self) + " has taken " + str(damage) + " damage!")

@rpc("authority")
func spawn_mana():
	$ManaGiver.give()

func _to_string() -> String:
	return "TOWER: " + str(global_position)
