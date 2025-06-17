extends CharacterBody2D

@export var max_health: int = 100
var jumpTime: float = 6./12.;
@export var jumpCooldown: float = 1.0;
@export var maxJumpDistance: float = 100.0
@export var health: int = max_health
@export var damage: int = 10
@export var target: Node2D

@onready var board = get_parent().get_node("GameBoard")


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
	# if NetworkManager.is_client(): return
	# GlobalLog.server_log(str(jump_target) + " " + str(jump_target == null) + " " + str(is_spawning))
	if can_jump:
		var dir = target.position - position
		var dist = dir.length()
		dir = dir.normalized()
		jump_target = position + dir * min(dist, maxJumpDistance)
		start_jump()
	
	if NetworkManager.is_server():
		if is_jumping:
			position += (jump_target - position) * delta / jumpTime

	
	# Optional: Add some debug visualization
	queue_redraw()

func start_jump() -> void:
	$Anim.play("Jump")
	is_jumping = true
	can_jump = false
	await get_tree().create_timer(jumpTime).timeout
	is_jumping = false
	jump_target = null

	await get_tree().create_timer(jumpCooldown).timeout
	can_jump = true

func _draw() -> void:
	if jump_target != null:
		# Draw a line to the target
		draw_line(Vector2.ZERO, to_local(jump_target), Color.RED, 2.0)

func _on_anim_animation_finished() -> void:
	if is_spawning:
		is_spawning = false
		can_jump = true

		$Anim.play("Idle")

# @rpc("authority")
# func play_anim(name: String) -> void:
# 	$Anim.play(name)
