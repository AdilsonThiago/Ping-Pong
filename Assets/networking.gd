extends Node
#My generic code for LAN games. Very optimized and structured.

#-------------------------------------------------------------------
#--------------------------LAN MODE---------------------------------
#-------------------------------------------------------------------

const DEFAULTIP = "127.0.0.1"
const DEFAULTPORT = 6007
const DEFAULTPLAYERS = 2

var ip = DEFAULTIP
var tsname = "Jogador"
var ID = ""
var players = []
var gateway = null
var peer = null
var connection_error = false
var server = false
var running_multiplayer = false
var game_running = false

func _ready():
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")
	players.clear()
	pass

func _connected_to_server():
	rpc("_register_player", get_tree().get_network_unique_id(), tsname)
	pass

func _peer_disconected(id):
	rpc("_remove_player", id)
	pass

func _server_disconnected():
#	if not get_tree().current_scene.name == "principal":
#		get_tree().change_scene("res://menuprincipal.tscn")
	get_tree().change_scene("res://MAIN.tscn")
	_connection_reset()
	pass

func _connection_failed():
	_connection_reset()
	pass

func _connection_error():
	return connection_error
	pass

func _connection_reset():
	ip = DEFAULTIP
	tsname = "Jogador"
	ID = ""
	players.clear()
	peer = null
	connection_error = true
	server = false
	running_multiplayer = false
	pass

func _clear_connection_error():
	connection_error = false
	pass

remote func _register_player(id, tname):
	if get_tree().is_network_server():
		for i in range(players.size()):
			rpc_id(id, "_register_player", players[i][0], players[i][1])
		rpc("_register_player", id, tname)
	players.append([id, tname])
	pass

func _attach_player_node(id, node):
	players[id].append(node)
	pass

remotesync func _remove_player(id):
	for i in range(players.size()):
		if players[i][0] == id:
#			if game_running:
#				players[i][2].queue_free()
			players.remove(i)
	pass

func _update_ip(novoip):
	ip = novoip
	pass

func _update_name(newname):
	tsname = newname
	pass

func _return_players_list():
	return players
	pass

func _return_id():
	return ID
	pass

func _return_name():
	return tsname
	pass

func _get_ip():
	var ips = IP.get_local_addresses()
	for i in range(ips.size()):
		if ips[i].begins_with("192"):
			return ips[i]
	pass

func _create_server():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULTPORT, DEFAULTPLAYERS)
	get_tree().set_network_peer(peer)
	ID = get_tree().get_network_unique_id()
	peer.connect("peer_disconnected", self, "_peer_disconected")
	_register_player(ID, tsname)
	server = true
	running_multiplayer = true
	pass

func _is_server():
	return server
	pass

func _enter_server():
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULTPORT)
	get_tree().set_network_peer(peer)
	ID = get_tree().get_network_unique_id()
	running_multiplayer = true
	pass

func _is_running_multiplayer():
	return running_multiplayer
	pass

func _start_game():
	if get_tree().is_network_server() and players.size() > 0:
		rpc("_change_scene")
	pass

remotesync func _change_scene():
	get_tree().change_scene("res://Assets/World.tscn")
	game_running = true
#	get_tree().paused = true
	pass
