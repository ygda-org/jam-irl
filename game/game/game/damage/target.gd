extends Node

@export var maxHealth: int = 100
@export var health: int = maxHealth
@export var affiliation: Affiliation.Type = Affiliation.Type.NEUTRAL

signal onDeath
signal onDamage

func _ready() -> void:
	health = maxHealth

func damage(damage: int):
	if not NetworkManager.is_server(): return
	
	health -= damage
	onDamage.emit(damage)
	
	if health <= 0:
		onDeath.emit()
