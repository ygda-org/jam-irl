extends StaticBody2D

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

func _on_target_on_death() -> void:
	GlobalLog.server_log(str(self) + " has died!")
	spawn_mana()
	rpc("spawn_mana")
	suicide()

func suicide():
	rpc("_suicide")
	_suicide()

@rpc("authority")
func _suicide():
	queue_free()

func _on_target_on_damage(damage: int) -> void:
	GlobalLog.server_log(str(self) + " has taken " + str(damage) + " damage!")

func _to_string() -> String:
	return "SWEATSHOP: " + str(global_position)

@rpc("authority")
func spawn_mana():
	$ManaGiver.give()
