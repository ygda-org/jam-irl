extends Node

@export var maxHealth: int = 100
@export var health: int = maxHealth
@export var affiliation: Affiliation.Type = Affiliation.Type.NEUTRAL

signal onDeath
signal onDamage

func _ready() -> void:
	health = maxHealth

func damage(damage: int):
	if NetworkManager.is_client(): return
	
	health -= damage
	onDamage.emit(damage)
	
	if health <= 0:
		onDeath.emit()
		var mana_giver = get_parent().get_node_or_null("ManaGiver")
		if mana_giver:
			mana_giver.give()
