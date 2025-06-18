extends Node2D

const FLOOR = preload("res://game/prefabs/alice_placeables/floor.tscn") # 0
const TOWER = preload("res://game/prefabs/alice_placeables/tower.tscn") # 1
const WALLH = preload("res://game/prefabs/alice_placeables/wallh.tscn") # 2
const WALLV = preload("res://game/prefabs/alice_placeables/wallv.tscn") # 3
const SWEATSHOP = preload("res://game/prefabs/alice_placeables/sweatshop.tscn") # 4
const SLIME = preload("res://game/game/slime/slime.tscn") # 5
const margin = 20

const structures = [FLOOR, TOWER, WALLH, WALLV, SWEATSHOP, SLIME]
const costs = [0,4,3,3,5,6]

var mouse_position: Vector2
var current_selected
var current_rotation = 0 # 0 or 1, o is horizontal 1 is vertical

@onready var board = get_parent().get_node("Arena").get_node("GameBoard")
@onready var game = get_parent()

var health = 4
@export var money_start = 8
@export var money = 0;

func _ready():
	$Panel/Selection.hide()

	if NetworkManager.is_server():
		change_money(money_start)

func _process(delta):
	if not NetworkManager.is_alice():
		return
	
	mouse_position = get_viewport().get_mouse_position()
	if Input.is_action_just_released("LeftClick"):
		placeTile()
	if Input.is_action_just_pressed("RightClick"):
		current_rotation = (current_rotation + 1) % 2
		if current_selected == 2 or current_selected == 3:
			_on_wall_pressed()
	if mouse_position.x < 620 and mouse_position.x > 20 and mouse_position.y < 520 and mouse_position.y > 20:
		$PlacePreview.show()
		$PlacePreview.position = Vector2i(margin, margin) + Vector2i(5, -5) + Vector2i(mouse_position) - Vector2i(int(mouse_position.x - margin) % 50, int(mouse_position.y - margin) % 50)
	else:
		$PlacePreview.hide()

func placeTile():
	if NetworkManager.client_assert(): return

	if current_selected == null or not (mouse_position.x < 620 and mouse_position.x > 20 and mouse_position.y < 520 and mouse_position.y > 20):
		return
	var mouse_pos = mouse_position
	mouse_pos = (mouse_pos - Vector2(margin, margin)) / 50
	mouse_pos = Vector2i(mouse_pos)
	if money - costs[current_selected] >= 0:
		rpc("_placeTile", current_selected, mouse_pos.y, mouse_pos.x)
	else:
		$PlacePreview.modulate = "dd00004b"
		$PlaceFailTimer.start()

@rpc("any_peer")
func _placeTile(current_selected, r, c):
	if not NetworkManager.is_server(): return
	GlobalLog.server_log("placeTile: " + str(current_selected) + " (" + str(r) + ", " + str(c) + ")")
	board.updateTile(current_selected, r, c)
	change_money(-costs[current_selected])

func _on_tower_pressed() -> void:
	$Panel/Selection.show()
	$PlacePreview.play("tower")
	$Panel/Selection.position = $Panel/Tower.position + Vector2(4, 4)
	#get_node("PlacePreview").texture = load("res://ASSETS/placeables/tower.png")
	current_selected = 1

func _on_wall_pressed() -> void:
	$Panel/Selection.show()
	$Panel/Selection.position = $Panel/Wall.position + Vector2(4, 4)
	if current_rotation == 1:
		$PlacePreview.play("wallV")
		current_selected = 3
	else:
		$PlacePreview.play("wallH")
		current_selected = 2
	#get_node("PlacePreview").texture = load("res://ASSETS/placeables/tower.png")

func _on_floortest_pressed() -> void: # this is the one for slimes now
	$Panel/Selection.show()
	$PlacePreview.play("goopy guy")
	$Panel/Selection.position = $Panel/Floortest.position + Vector2(4,4)
	#dec_health(1)
	#get_node("PlacePreview").texture = load("res://ASSETS/placeables/floor.png")
	current_selected = 5

func dec_health(delta=1) -> void:
	GlobalLog.log("Alice hit")
	health -= delta
	if health <= 0:
		game.win(NetworkManager.Role.Bob)
		health = 0
	
	# for idx in range($HealthBar.get_child_count()-health):
	$HealthBar.get_child(health).play("turbo_dead")

func change_money(change) -> void:
	if NetworkManager.server_assert(): return

	GlobalLog.server_log("change_money: " + str(money) + " (" + str(change) + ")")
	rpc("_change_money", change)
	_change_money(change)

@rpc("authority")
func _change_money(change):
	money += change
	if money < 0:
		money = 0
	$HealthBar/Money.text = "$"+str(money)

func _on_sweatshop_pressed() -> void:
	$Panel/Selection.show()
	$Panel/Selection.position = $Panel/Sweatshop.position + Vector2(4, 4)
	$PlacePreview.play("sweatshop")
	
	current_selected = 4

func _on_place_fail_timer_timeout() -> void:
	$PlacePreview.modulate = "ffffff4b"
