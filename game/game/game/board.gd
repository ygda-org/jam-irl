extends Node2D

var board = []

const FLOOR = preload("res://game/prefabs/alice_placeables/floor.tscn") # 0
const TOWER = preload("res://game/prefabs/alice_placeables/tower.tscn") # 1
const WALL = preload("res://game/prefabs/alice_placeables/wall.tscn") # 2
const SWEATSHOP = preload("res://game/prefabs/alice_placeables/sweatshop.tscn") # 3 
const margin = 20

const structures = [FLOOR, TOWER, WALL, SWEATSHOP]

var mouse_position: Vector2

var current_selected

func _ready():
	initializeBoard()
	updateTile(1, 7, 2)
	updateTile(1, 6, 2)
	updateTile(1, 5, 2)
	updateTile(1, 4, 5)
	updateTile(1, 0, 0)
	updateTile(1, 0, 2)
	updateTile(1, 0, 4)

func initializeBoard() -> void:
	for r in range(10):
		board.append([])
		for c in range(12):
			board[r].append(FLOOR.instantiate())
			board[r][c].position = Vector2(c*50, r*50) + Vector2(margin, margin)
			add_child(board[r][c])
			board[r][c].z_index = 0

@rpc("any_peer")
func updateTile(newTileId: int, r, c) -> void:
	if (r >= 10 or c >= 12 or newTileId == null):
		return
	var newTile = structures[newTileId].instantiate()
	var oldPos = board[r][c].position
	newTile.position = oldPos
	newTile.z_index = (r if newTileId != 0 else 0)
	board[r][c].queue_free()
	board[r][c] = newTile
	add_child(newTile)
