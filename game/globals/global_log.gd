extends Node

func server_log(statement : String):
	assert(NetworkInfo.is_server())
	print("SERVER: " + statement)

func client_log(statement : String):
	assert(NetworkInfo.is_client())
	print("CLIENT: " + statement)

func log(statement : String):
	if NetworkInfo.is_server():
		server_log(statement)
	else:
		client_log(statement)
