extends Node

enum State {
	Client,
	Server
}

## Match making server info:
@export var match_making_address = "http://localhost:8000"
##

@export var state: State = State.Server

## Game instance info:
@export var port: int = 9999 # 9999 is default game instance port, docker container binds it to port 10000-19999 on host machine
@export var code: String = "default"
##

## Client info:
@export var user_id: String = "none"
@export var address_with_port: String = "ws://localhost:9999"
##


func get_address_with_protocol(tls: bool = false) -> String:
	return address_with_port

func is_server() -> bool:
	return state == State.Server

func is_client() -> bool:
	return state == State.Client
