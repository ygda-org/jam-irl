extends Node2D

#@onready var bob = $"../../../../../../../game/arena/bob"
const mana_particle = preload("res://game/game/mana/mana_particle.tscn")
const mana_to_give = 8
var mana = []
var rng = RandomNumberGenerator.new()

func _ready():
	give() # testing

func give():
	for i in range(mana_to_give):
		mana.append(mana_particle.instantiate())
		add_child(mana[i])
		mana[i].velocity = Vector2(randi_range(-100, 100), randi_range(-100, 100))
