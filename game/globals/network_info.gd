extends Node

enum State {
	Alice,
	Bob,
	Server
}

@export var address: String = "localhost"
@export var port: int = 9999 # 9999 is default test port, 10000-19999 are actual game instance ports
@export var state: State = State.Server

func get_address(tls: bool = false) -> String:
	var protocol: String = ["ws://", "ws://"][int(tls)]
	
	return protocol + address + ":" + str(port)

func is_server() -> bool:
	return state == State.Server
