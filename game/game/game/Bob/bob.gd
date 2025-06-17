extends CharacterBody2D

const SPEED: int = 10000
const ATTACK_COOLDOWN: float = 0.75

var can_attack: bool = true

var input: Vector2 = Vector2(0, 0)
@onready var game = get_tree().root.get_node("Game")
@onready var bob_ui = get_node("../../BobUI")

var mana: int = 100

func _ready() -> void:
	if not NetworkManager.is_server(): # Disable collisions if it's a client.
		%CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	if not NetworkManager.is_server():
		return
	

	if input != Vector2.ZERO:
		if input.x > 0:
			%Anim.flip_h = true
		elif input.x < 0:
			%Anim.flip_h = false
			
		%Anim.play("run")
		
	else:
		$Anim.play("idle")
		
	velocity = delta * SPEED * input
	
	move_and_slide()

func health() -> int:
	return $Target.health

func _on_target_on_death() -> void:
	GlobalLog.server_log("Bob has died!")
	game.win(NetworkManager.Role.Alice)

func _on_target_on_damage(damage: int) -> void:
	GlobalLog.server_log("Bob has taken " + str(damage) + " damage!")
	rpc("__on_target_on_damage", damage)

@rpc("any_peer")
func attack():
	if can_attack:
		can_attack = false
		%BobAttackCooldown.start(ATTACK_COOLDOWN)
		%Anim.play("sword1")
		var attacked_bodies: Array[Node2D] = %BobAttackArea.get_overlapping_bodies() + %BobAttackArea.get_overlapping_areas()
		for body in attacked_bodies:
			if body.is_in_group("Damageable"):
				body.damage()
		

@rpc("authority")
func __on_target_on_damage(damage: int) -> void:
	bob_ui.update_health_bar(health())

func _to_string() -> String:
	return "BOB"


func _on_bob_attack_cooldown_timeout() -> void:
	can_attack = true
