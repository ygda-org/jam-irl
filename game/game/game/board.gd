extends Node2D

var board = []

const FLOOR = preload("res://game/prefabs/alice_placeables/floor.tscn") # 0
const TOWER = preload("res://game/prefabs/alice_placeables/tower.tscn") # 1
const WALLH = preload("res://game/prefabs/alice_placeables/wallh.tscn") # 2
const WALLV = preload("res://game/prefabs/alice_placeables/wallv.tscn") # 3
const SWEATSHOP = preload("res://game/prefabs/alice_placeables/sweatshop.tscn") # 4
const SLIME = preload("res://game/game/slime/slime.tscn") # 5
const margin = 20

const structures = [FLOOR, TOWER, WALLH, WALLV, SWEATSHOP, SLIME]

var mouse_position: Vector2

var current_selected

func _ready():
	initializeBoard()

func initializeBoard() -> void:
	for r in range(10):
		board.append([])
		for c in range(12):
			board[r].append(FLOOR.instantiate())
			board[r][c].position = Vector2(c*50, r*50) + Vector2(margin, margin)
			add_child(board[r][c])
			board[r][c].z_index = 0

func updateTile(newTileId: int, r, c) -> void:
	if NetworkManager.server_assert(): return
	rpc("_updateTile", newTileId, r, c)
	_updateTile(newTileId, r, c)

@rpc("authority")
func _updateTile(newTileId: int, r, c) -> void:
	if (r >= 10 or c >= 12 or newTileId == null):
		return
	var newTile = structures[newTileId].instantiate()
	var oldPos = board[r][c].position
	newTile.position = oldPos
	newTile.z_index = (r if newTileId != 0 else 0)
	board[r][c].queue_free()
	board[r][c] = newTile
	add_child(newTile)
