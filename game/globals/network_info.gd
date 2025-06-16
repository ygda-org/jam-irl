extends Node

enum State {
	Client,
	Server
}

@export var state: State = State.Server
@export var address: String = "localhost"
@export var port: int = 9999 # 9999 is default game instance port, docker container binds it to port 10000-19999 on host machine
@export var code: String = "default"

func get_address_with_port(tls: bool = false) -> String:
	var protocol: String = ["ws://", "wss://"][int(tls)]
	
	return protocol + address + ":" + str(port)

func is_server() -> bool:
	return state == State.Server
