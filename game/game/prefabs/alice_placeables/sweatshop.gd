extends Node2D

@export var production_rate: int = 1
@export var production_delay: float = 3.0
@onready var alice = get_tree().root.get_node("Game").get_node("AliceController")

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = production_delay
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	if alice == null:
		alice = get_tree().root.get_node("Game").get_node("AliceController")

	# TODO: production animation
	alice.change_money(+production_rate)
