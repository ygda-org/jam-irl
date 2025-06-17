extends CharacterBody2D

var jumpTime: float = 6./12.;
@export var jumpCooldown: float = 1.0;
@export var maxJumpDistance: float = 100.0
@export var damage: int = 10
@export var target: Node2D

@onready var board = get_parent().get_node("GameBoard")
@onready var attack_area: Area2D = $AttackArea

@export var is_spawning: bool = true
@export var is_jumping: bool = false
@export var can_jump: bool = false
@export var jump_target = null

func _ready() -> void:
	target = get_parent().get_node("Bob")
	if target == null:
		push_error("Bob not found in scene!")
	
	$Anim.play("Spawn")

func _physics_process(delta: float) -> void:
	if can_jump:
		var dir = target.position - position
		var dist = dir.length()
		dir = dir.normalized()
		jump_target = position + dir * min(dist, maxJumpDistance)
		start_jump()
	
	if NetworkManager.is_server():
		if is_jumping:
			position += (jump_target - position) * delta / jumpTime


func start_jump() -> void:
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
