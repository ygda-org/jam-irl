extends CharacterBody2D

var jumpTime: float = 6./12.;
@export var jumpCooldown: float = 1.0;
@export var maxJumpDistance: float = 100.0
@export var damage: int = 10
@export var target: Node2D

@onready var board = get_parent().get_node("GameBoard")
@onready var attack_area: Area2D = $AttackArea

var is_spawning: bool = true
var is_jumping: bool = false
var can_jump: bool = false
var jump_target = null
var is_dead = false

func _ready() -> void:
	target = get_parent().get_node("Bob")
	if target == null:
		target = get_parent().get_parent().get_node("Bob")
		board = get_parent()
	#	target = 
	if target == null:
		push_error("Bob not found in scene!")
	
	$Anim.play("Spawn")

func _physics_process(delta: float) -> void:
	if NetworkManager.is_client(): return
	
	if can_jump:
		var dir = target.position - position
		var dist = dir.length()
		dir = dir.normalized()
		jump_target = position + dir * min(dist, maxJumpDistance)
		start_jump()
	
	if is_jumping:
		position += (jump_target - position) * delta / jumpTime


func start_jump() -> void:
	if is_dead or is_jumping or not can_jump or is_spawning: return
	GlobalLog.server_log("SLIME: " + str(self) + " is jumping to " + str(jump_target))
	$Anim.play("Jump")
	is_jumping = true
	can_jump = false
	await get_tree().create_timer(jumpTime).timeout
	is_jumping = false
	jump_target = null

	if is_target_in_attack_range():
		target.get_node("Target").damage(damage)

	await get_tree().create_timer(jumpCooldown).timeout
	can_jump = true

func is_target_in_attack_range() -> bool:
	if target == null:
		return false
		
	var bodies = attack_area.get_overlapping_bodies()
	return bodies.has(target)


func _on_anim_animation_finished() -> void:
	if is_spawning:
		is_spawning = false
		can_jump = true

		$Anim.play("Idle")

func _on_target_on_death() -> void:
	GlobalLog.server_log(str(self) + " has died!")
	is_dead = true
	suicide()

func suicide():
	rpc("_suicide")
	_suicide()

@rpc("authority")
func _suicide():
	$Anim.stop()
	$Anim.play("Death")
	await $Anim.animation_finished
	queue_free()

func _on_target_on_damage(damage: int) -> void:
	# only hurt if you are alive
	if get_node("Target").health > 0:
		rpc("__on_target_on_damage", damage)
		__on_target_on_damage(damage)

@rpc("authority")
func __on_target_on_damage(damage: int) -> void:
	GlobalLog.log(str(self) + " has taken " + str(damage) + " damage!")
	$Anim.play("Hurt")
	if not can_jump: return
	can_jump = false
	await $Anim.animation_finished
	can_jump = true

func _to_string() -> String:
	return "SLIME: " + str(global_position)
