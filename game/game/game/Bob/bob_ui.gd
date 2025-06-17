extends Node2D

@export var bob: CharacterBody2D = null

@onready var health_bar: TextureProgressBar = $Health/HealthBar
@onready var mana_bar: TextureProgressBar = $Node2D/ManaBar

func _ready() -> void:
	update_health_bar(bob.health())
	update_mana_bar(bob.mana)

func update_health_bar(health: int) -> void:
	health_bar.value = health
	
func update_mana_bar(mana: int) -> void:
	mana_bar.value = mana
