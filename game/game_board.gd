extends Node2D

var board = []

const FLOOR = preload("res://game/alice_placeables/floor.tscn")
const TOWER = preload("res://game/alice_placeables/tower.tscn")

func _ready():
	initializeBoard()
	updateTile(TOWER, 7, 2)
	updateTile(TOWER, 6, 2)
	updateTile(TOWER, 5, 2)
	updateTile(TOWER, 4, 5)

func initializeBoard():
	for r in range(10):
		board.append([])
		for c in range(12):
			board[r].append(FLOOR.instantiate())
			board[r][c].position = Vector2(c*50, r*50)
			add_child(board[r][c])
			board[r][c].z_index = 0


func updateTile(newTileConst, r, c):
	var newTile = newTileConst.instantiate()
	var oldPos = board[r][c].position
	newTile.position = oldPos
	newTile.z_index = (r if newTileConst != FLOOR else 0)
	board[r][c].queue_free()
	board[r][c] = newTile
	add_child(newTile)
