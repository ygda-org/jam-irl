extends Node2D

@onready var winner_label: Label = $Label

func _ready() -> void:
	var winner: String = ""
	if GameManager.winner == NetworkManager.Role.Alice:
		winner = "Alice"
	else:
		winner = "Bob"
	winner_label.text = winner + " wins!"

func _on_home_pressed() -> void:
	SceneSwitcher.goto_start()
