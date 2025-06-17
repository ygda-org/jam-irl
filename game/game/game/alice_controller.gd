extends Node2D

const FLOOR = preload("res://game/prefabs/alice_placeables/floor.tscn") # 0
const TOWER = preload("res://game/prefabs/alice_placeables/tower.tscn") # 1
const margin = 20

const structures = [FLOOR, TOWER]

var mouse_position: Vector2
var current_selected

@onready var board = get_parent().get_node("GameBoard")

var health = 4

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
	if current_selected == null:
		return
	var mouse_pos = mouse_position
	mouse_pos = (mouse_pos - Vector2(margin, margin)) / 50
	mouse_pos = Vector2i(mouse_pos)
	board.rpc("updateTile", current_selected, mouse_pos.y, mouse_pos.x)
	board.updateTile(current_selected, mouse_pos.y, mouse_pos.x)

func _on_tower_pressed() -> void:
	$PlacePreview.play("tower")
	#get_node("PlacePreview").texture = load("res://ASSETS/placeables/tower.png")
	current_selected = 1

func _on_wall_pressed() -> void:
	$PlacePreview.play("wall")
	#get_node("PlacePreview").texture = load("res://ASSETS/placeables/tower.png")
	current_selected = 1

func _on_floortest_pressed() -> void:
	$PlacePreview.play("floorTEST")
	dec_health()
	#get_node("PlacePreview").texture = load("res://ASSETS/placeables/floor.png")
	current_selected = 0

func dec_health() -> void:
	health -= 1
	health %= 4
	for idx in range(health,$HealthBar.get_child_count()):
		$HealthBar.get_child(idx).visible = false
	if health <= 0:
		print("Allice died :(")
