extends Node2D

const BOB_MANAGER = preload("res://game/game/Bob/bob_manager.tscn")
const GENERIC_PROJECTILE = preload("res://game/game/GenericProjectile/generic_projectile.tscn")
var winner: NetworkManager.Role = NetworkManager.Role.None

@export var bob_reference: Node2D = null

func _ready():
	_update_debug_label()

	add_child(load("res://game/game/alice_controller.tscn").instantiate())
	
	if NetworkManager.is_bob():
		$AliceController/Panel/Tower.disabled = true
		$AliceController/Panel/Wall.disabled = true
		$AliceController/Panel/Floortest.disabled = true
		$AliceController/Panel/Sweatshop.disabled = true
	
	if NetworkManager.is_server():
		var bob_manager = BOB_MANAGER.instantiate()
		bob_manager.set_multiplayer_authority(NetworkManager.server_data.bob_id)
		add_child(bob_manager)
	
func _update_debug_label():
	%DebugLabel.text = "Role: "
	if NetworkManager.is_alice():
		%DebugLabel.text += "Alice"
	elif NetworkManager.is_bob():
		%DebugLabel.text += "Bob"
	elif NetworkManager.is_server():
		%DebugLabel.text += "Server"
	if NetworkManager.verified:
		%DebugLabel.text += " | Verified"
	
	%DebugLabel.text += " | URL: " + NetworkManager.get_address_with_protocol() + " [" + str(NetworkManager.code) + "]"


func _on_debug_end_game_pressed() -> void:
	if NetworkManager.is_server():
		end_match()
		get_tree().quit(0)
	else:
		rpc("end_match")
		# SceneSwitcher.goto_start()

@rpc("any_peer")
func end_match():
	if not NetworkManager.is_server():
		return

	GlobalLog.server_log("Ending game instance! Goodbye!")
	
	var res = await HttpWrapper.request(%AwaitableHTTP, "/match/end", HTTPClient.METHOD_POST, {
		"matchId": NetworkManager.match_id,
		"code": NetworkManager.code
	})
	
	if res:
		GlobalLog.server_log("Successfully told matchmaking server that game is ending.")
	else:
		GlobalLog.server_log("Failed to tell matchmaking server game ended.")
	
	get_tree().quit(0)

func win(role: NetworkManager.Role):
	GameManager.win(role)
	rpc("_win", role)
	end_match()

@rpc("authority")
func _win(role: NetworkManager.Role):
	win(role)

func update_bob_input(input: Vector2):
	%Bob.input = input

## ignored_body is optional
func summon_projectile(spawn_position : Vector2, direction : Vector2, proj_settings : ProjectileSettings, ignored_body : Variant = null):
	var projectile_instance = GENERIC_PROJECTILE.instantiate()
	projectile_instance.settings = proj_settings
	projectile_instance.direction = direction
	projectile_instance.position = spawn_position
	projectile_instance.ignored_body = ignored_body
	$Arena.add_child(projectile_instance)
