extends Node2D

const mana_particle = preload("res://game/game/mana/mana_particle.tscn")
@export var mana_to_give = 30
var mana = []
var rng = RandomNumberGenerator.new()

func _ready():
	pass

func give():
	for i in range(mana_to_give):
		mana.append(mana_particle.instantiate())
		get_parent().get_parent().get_parent().add_child(mana[i])
		mana[i].velocity = Vector2(randi_range(-100, 100), randi_range(-100, 100))
		mana[i].position = global_position
