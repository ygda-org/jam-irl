extends Node2D

const mana_particle = preload("res://game/game/mana/mana_particle.tscn")
@export var mana_to_give = 30
var mana = []
var rng = RandomNumberGenerator.new()

func _ready():
	pass

func give():
	if NetworkManager.server_assert(): return 

	var mana_inits = []
	for i in range(mana_to_give):
		mana_inits.append({
			'velocity': Vector2(randi_range(-100, 100), randi_range(-100, 100)),
			'position': global_position
		})

	rpc("_give", mana_inits)
	_give(mana_inits)

@rpc("authority")
func _give(mana_inits):
	for i in range(mana_inits.size()):
		mana.append(mana_particle.instantiate())
		get_parent().get_parent().get_parent().add_child(mana[i])
		mana[i].velocity = mana_inits[i]['velocity']
		mana[i].position = mana_inits[i]['position']
