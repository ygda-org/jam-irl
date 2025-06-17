extends Object
class_name ServerData

class ClientData:
	var role: NetworkManager.Role
	var is_verified: bool
	
	func ClientData():
		role = NetworkManager.Role.None
		is_verified = false

# peer id -> ClientData object, godot should really have a way of statically typing that
var id_to_client_data: Dictionary = {} 
var alice_id: int = -1
var bob_id: int = -1

func peer_exists(id: int) -> bool:
	return id_to_client_data.keys().has(id)

# Returns true if peer is added, false if the room is full
func add_peer(id: int) -> bool:
	if id_to_client_data.size() >= 2:
		return false
	else:
		id_to_client_data[id] = ClientData.new()
		return true
		
func remove_peer(id: int) -> void:
	id_to_client_data.erase(id)

func verify_peer(id: int) -> void:
	if not peer_exists(id):
		print("Tried to verify a peer that wasn't connected!")
		return
	
	id_to_client_data[id].is_verified = true

func is_verified(id: int) -> bool:
	if not peer_exists(id):
		print("Tried seeing if a peer that wasn't connected is verified!")
		return false
	
	return id_to_client_data[id].is_verified

func get_other_id(id: int):
	if id_to_client_data.keys()[1] == id:
		return id_to_client_data.keys()[0]
	else:
		return id_to_client_data.keys()[1]

func update_client_ids(id: int, role: NetworkManager.Role) -> void:
	if not peer_exists(id):
		print("Tried to start a game with a peer id that wasn't connected!")
		return
	
	if role == NetworkManager.Role.Alice:
		alice_id = id
		bob_id = get_other_id(id)
	elif role == NetworkManager.Role.Bob:
		bob_id = id
		alice_id = get_other_id(id)
	
	
