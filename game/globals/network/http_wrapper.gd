extends Node

func test(http_node):
	var headers = ["Content-Type: applications/json"]
	var user_request_res = await http_node.async_request(NetworkManager.match_making_address + "/user/", headers, HTTPClient.METHOD_POST)
	if user_request_res.success() and user_request_res.status_ok():
		var json = user_request_res.body_as_json()
		NetworkManager.user_id = json["userId"]
		GlobalLog.client_log("Retrieved userID %s from matchmaking server." % NetworkManager.user_id)
	else:
		GlobalLog.client_log("Failed to get userID from matchmaking server.")

func request(http_node, path: String, method: int, body = null):
	var headers = []
	if method == HTTPClient.METHOD_POST:
		headers.append("Content-Type: application/json")

	var json = JSON.stringify(body) if body else ""
	var res = await http_node.async_request(NetworkManager.match_making_address + path, headers, method, json)
	print("recv: %s" % str(res.body_as_json()))
	if res.success() and res.status_ok():
		body = res.body_as_json()
		GlobalLog.log("Request to %s returned %s" % [path, body])
		return body

	GlobalLog.log("Request to %s failed with status %s" % [path, res.status])
	return null
