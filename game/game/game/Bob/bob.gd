extends CharacterBody2D

const SPEED: int = 10000
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

@rpc("authority")
func __on_target_on_damage(damage: int) -> void:
	bob_ui.update_health_bar(health())
	
