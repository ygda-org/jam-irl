extends Node2D

var input: Vector2 = Vector2(0, 0)	
const BOB_FIREBALL = preload("res://game/game/GenericProjectile/ProjectileSettingResources/bob_fireball.tres")
var summon_request = false

func _on_input_tick_timeout() -> void:
	if not NetworkManager.is_bob():
		return
	var old_input = input
	input = Input.get_vector("Left", "Right", "Up", "Down")
	
	if not summon_request and Input.is_action_just_pressed("Shoot"):
		summon_request = true
	
	if summon_request:# TODO Factor in timer to delay request and slow shooting speed
		summon_request = false
		rpc("request_projectile", input)
		request_projectile(input)
		pass
	
	if not old_input == input:
		rpc_id(1, "send_input", to_bitmask(input))

@rpc("any_peer")
func request_projectile(direction : Vector2):
	#GlobalLog.log("Projectile Requested")
	var bob = $"../Arena/Bob"
	get_parent().summon_projectile(bob.global_position, direction, BOB_FIREBALL, bob)

@rpc("any_peer")
func send_input(input_bitmask: int):
	if not NetworkManager.is_server():
		return
	
	get_parent().update_bob_input(from_bitmask(input_bitmask))

func to_bitmask(inp: Vector2) -> int: # Only send an integer for smaller packets
	var mask := 0
	if inp.x < -0.1:
		mask |= 1       # Left
	if inp.x > 0.1:
		mask |= 2       # Right
	if inp.y < -0.1:
		mask |= 4       # Up
	if inp.y > 0.1:
		mask |= 8       # Down
	return mask

func from_bitmask(mask: int) -> Vector2: # Parse bitmask
	var inp := Vector2.ZERO
	if mask & 1:
		inp.x -= 1
	if mask & 2:
		inp.x += 1
	if mask & 4:
		inp.y -= 1
	if mask & 8:
		inp.y += 1
	return inp.normalized()
