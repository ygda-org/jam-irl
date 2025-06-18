extends CharacterBody2D

const SPEED: int = 10000
const ATTACK: int = 20
const ATTACK_COOLDOWN: float = 0.75
const ATTACK_WINDDOWN: float = 1.5

var can_attack: bool = true

var input: Vector2 = Vector2(0, 0)
@onready var game = get_tree().root.get_node("Game")
@onready var bob_ui = get_node("../../BobUI")

var mana: int = 100

var queued_next_attack = 0
var prev_attack = 0

func _ready() -> void:
	if not NetworkManager.is_server(): # Disable collisions if it's a client.
		%CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	if not NetworkManager.is_server():
		return
	
	
	if can_attack:
		velocity = delta * SPEED * input
		if input != Vector2.ZERO:
			if input.x > 0:
				%Anim.flip_h = true
			elif input.x < 0:
				%Anim.flip_h = false
				
			%Anim.play("run")
			
		else:
			$Anim.play("idle")
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func health() -> int:
	return $Target.health

func update_mana(delta: int) -> void:
	mana += delta
	bob_ui.update_mana_bar(mana)

func _on_target_on_death() -> void:
	GlobalLog.server_log("Bob has died!")
	game.win(NetworkManager.Role.Alice)

func _on_target_on_damage(damage: int) -> void:
	GlobalLog.server_log("Bob has taken " + str(damage) + " damage!")
	rpc("__on_target_on_damage", damage)

@rpc("any_peer")
func attack(current = 1):
	if can_attack:
		prev_attack = current
		$Anim.flip_h = not $Anim.flip_h if current == 1 else $Anim.flip_h
		can_attack = false
		if current == 3:
			$BobWinddown.start(ATTACK_WINDDOWN)
		else:
			%BobAttackCooldown.start(ATTACK_COOLDOWN)
		%Anim.play("sword" + str(current))
		var attacked_bodies: Array = (%"BobAttackArea" if current == 1 else $BobAttackArea2 if current == 2 else $BobAttackArea3).get_overlapping_bodies() + %BobAttackArea.get_overlapping_areas()
		
		for body: Node2D in attacked_bodies:
			if "AttackArea" in body.name:
				continue
			var target = body.find_child("Target")
			if target and target.affiliation != Affiliation.Type.PLAYER:
				target.damage(ATTACK)
	else:
		queued_next_attack = prev_attack + 1

@rpc("authority")
func __on_target_on_damage(damage: int) -> void:
	bob_ui.update_health_bar(health())

func _to_string() -> String:
	return "BOB"


func _on_bob_attack_cooldown_timeout() -> void:
	can_attack = true
	if queued_next_attack >= 1 and queued_next_attack <= 3 and queued_next_attack != prev_attack:
		attack(queued_next_attack)


func _on_bob_winddown_timeout():
	queued_next_attack = 0
	prev_attack = 0
	can_attack = true
