extends Node
var winner: NetworkManager.Role = NetworkManager.Role.None

func win(role: NetworkManager.Role) -> void:
	winner = role
	SceneSwitcher.goto_victory_screen(role)
