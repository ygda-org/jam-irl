extends Node

@export var maxHealth: int = 100
@export var health: int = maxHealth
@export var affiliation = Affiliation.NEUTRAL

signal died

func _ready() -> void:
	health = maxHealth

func damage(damage: int):
	if not NetworkManager.is_server(): return
	
	health -= damage
	
	if health <= 0:
		died.emit()
