extends Node

func server_log(statement : String):
	assert(NetworkManager.is_server())
	print("SERVER: " + statement)

func client_log(statement : String):
	assert(NetworkManager.is_client())
	print("CLIENT: " + statement)

func log(statement : String):
	if NetworkManager.is_server():
		server_log(statement)
	else:
		client_log(statement)
