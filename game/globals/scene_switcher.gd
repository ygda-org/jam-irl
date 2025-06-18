extends Node

var current_scene: Node = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(-1)

func goto_scene(path):
	_deferred_goto_scene.call_deferred(path)

func goto_lobby():
	goto_scene("res://game/lobby/lobby.tscn")

func goto_game():
	goto_scene("res://game/game/game.tscn")

func goto_start():
	goto_scene("res://game/start/start_menu.tscn")

func goto_victory_screen(winner: NetworkManager.Role):
	goto_scene("res://game/victory/victory_screen.tscn")

func _deferred_goto_scene(path):
	current_scene.free()
	
	# Instanciate and Load the next scene
	var scene_loader = ResourceLoader.load(path)
	current_scene = scene_loader.instantiate()
	
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

func start_menu_with_error(msg: String = "Failed to connect to server.") -> void:
	if NetworkManager.is_server():
		GlobalLog.server_log(msg)
	else:
		GlobalLog.client_log(msg)
	# TODO: display the error message in the main menu scene
	goto_start()
