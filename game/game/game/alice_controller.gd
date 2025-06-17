extends Node2D

const FLOOR = preload("res://game/prefabs/alice_placeables/floor.tscn") # 0
const TOWER = preload("res://game/prefabs/alice_placeables/tower.tscn") # 1
const WALL = preload("res://game/prefabs/alice_placeables/wall.tscn") # 2
const SWEATSHOP = preload("res://game/prefabs/alice_placeables/sweatshop.tscn") # 3
const margin = 20

const structures = [FLOOR, TOWER, WALL, SWEATSHOP]
const costs = [0,4,1,5]

var mouse_position: Vector2
var current_selected

@onready var board = get_parent().get_node("Arena").get_node("GameBoard")

var health = 4
var money = 20
var number_of_children_worked_to_the_bone = 0

func _process(delta):
	mouse_position = get_viewport().get_mouse_position()
	if Input.is_action_just_released("LeftClick"):
		placeTile()
	if mouse_position.x < 620 and mouse_position.x > 20 and mouse_position.y < 520 and mouse_position.y > 20:
		$PlacePreview.show()
		$PlacePreview.position = Vector2i(margin, margin) + Vector2i(5, -5) + Vector2i(mouse_position) - Vector2i(int(mouse_position.x - margin) % 50, int(mouse_position.y - margin) % 50)
	else:
		$PlacePreview.hide()
	
func placeTile():
	if current_selected == null or not (mouse_position.x < 620 and mouse_position.x > 20 and mouse_position.y < 520 and mouse_position.y > 20):
		return
	var mouse_pos = mouse_position
	mouse_pos = (mouse_pos - Vector2(margin, margin)) / 50
	mouse_pos = Vector2i(mouse_pos)
	if money - costs[current_selected] >= 0:
		board.rpc("updateTile", current_selected, mouse_pos.y, mouse_pos.x)
		board.updateTile(current_selected, mouse_pos.y, mouse_pos.x)
		change_money(-costs[current_selected])

func _on_tower_pressed() -> void:
	$PlacePreview.play("tower")
	#get_node("PlacePreview").texture = load("res://ASSETS/placeables/tower.png")
	current_selected = 1

func _on_wall_pressed() -> void:
	$PlacePreview.play("wallH")
	#get_node("PlacePreview").texture = load("res://ASSETS/placeables/tower.png")
	current_selected = 2

func _on_floortest_pressed() -> void:
	$PlacePreview.play("floorTEST")
	dec_health()
	#get_node("PlacePreview").texture = load("res://ASSETS/placeables/floor.png")
	current_selected = 0

func dec_health() -> void:
	health -= 1
	if health <= 0:
		print("Allice died :(")
		health = 0
	for idx in range($HealthBar.get_child_count()-health):
		$HealthBar.get_child(idx).play("turbo_dead")

func change_money(change) -> void:
	money += change
	if money < 0:
		money = 0
	$HealthBar/Money.text = "$"+str(money)

func _on_sweatshop_pressed() -> void:
	number_of_children_worked_to_the_bone += 1
	$PlacePreview.play("sweatshop")
	
	current_selected = 3

func _on_money_timer_timeout() -> void:
	change_money(number_of_children_worked_to_the_bone)
