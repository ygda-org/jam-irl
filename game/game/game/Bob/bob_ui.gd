extends Node2D

@export var bob: CharacterBody2D = null

@onready var health_bar: TextureProgressBar = $Health/HealthBar
@onready var mana_bar: TextureProgressBar = $Node2D/ManaBar

func _ready() -> void:
	bob.get_node("Target").onDamage.connect(update_health)
	
func update_health() -> void:
	health_bar.value = bob.get_node("Target").health
	
func update_mana() -> void:
	pass # implement when mana gets added 
