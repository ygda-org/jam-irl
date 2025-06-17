extends Node2D

var board = []

const FLOOR = preload("res://game/alice_placeables/floor.tscn")
const TOWER = preload("res://game/alice_placeables/tower.tscn")
const margin = 20

var mouse_position: Vector2

var current_selected

func _ready():
	initializeBoard()
	updateTile(TOWER, 7, 2)
	updateTile(TOWER, 6, 2)
	updateTile(TOWER, 5, 2)
	updateTile(TOWER, 4, 5)
	updateTile(TOWER, 0, 0)
	updateTile(TOWER, 0, 2)
	updateTile(TOWER, 0, 4)

func _process(delta):
	mouse_position = get_viewport().get_mouse_position()
	if Input.is_action_just_released("LeftClick"):
		placeTile()
	get_node("PlacePreview").position = Vector2i(margin, margin) + Vector2i(5, -5) + Vector2i(mouse_position) - Vector2i(int(mouse_position.x - margin) % 50, int(mouse_position.y - margin) % 50)

func initializeBoard() -> void:
	for r in range(10):
		board.append([])
		for c in range(12):
			board[r].append(FLOOR.instantiate())
			board[r][c].position = Vector2(c*50, r*50) + Vector2(margin, margin)
			add_child(board[r][c])
			board[r][c].z_index = 0


func updateTile(newTileConst, r, c) -> void:
	if (r >= 10 or c >= 12 or newTileConst == null):
		return
	var newTile = newTileConst.instantiate()
	var oldPos = board[r][c].position
	newTile.position = oldPos
	newTile.z_index = (r if newTileConst != FLOOR else 0)
	board[r][c].queue_free()
	board[r][c] = newTile
	add_child(newTile)

func placeTile() -> void:
	var mouse_pos = mouse_position
	mouse_pos = (mouse_pos - Vector2(margin, margin)) / 50
	mouse_pos = Vector2i(mouse_pos)
	updateTile(current_selected, mouse_pos.y, mouse_pos.x)


func _on_tower_pressed() -> void:
	$PlacePreview.play("tower")
	#get_node("PlacePreview").texture = load("res://ASSETS/placeables/tower.png")
	current_selected = TOWER


func _on_floortest_pressed() -> void:
	$PlacePreview.play("floorTEST")
	#get_node("PlacePreview").texture = load("res://ASSETS/placeables/floor.png")
	current_selected = FLOOR
