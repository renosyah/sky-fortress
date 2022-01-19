extends Node

onready var _terrain = $terrain
onready var _server_advertise = $server_advertiser
onready var _ui = $ui

# Called when the node enters the scene tree for the first time.
func _ready():
	_terrain.season = "summer"
	_terrain.blank_map = false
	_terrain.generate()
	
	if Global.mode == Global.MODE_HOST:
		init_host()
	else:
		init_client()
	
################################################################
# network connection for host
func init_host():
	Network.connect("server_player_connected", self ,"_server_player_connected")
	Network.connect("server_disconnected", self , "_server_disconnected")
	Network.connect("connection_closed", self ,"_connection_closed")
	
	var err = Network.create_server(Global.server.max_player, Global.server.port , {})
	if err != OK:
		return
	
func _server_player_connected(_player_network_unique_id : int, _player : Dictionary):
	_server_advertise.setup()
	_server_advertise.serverInfo["name"] = Global.player_data.name
	_server_advertise.serverInfo["port"] = Global.server.port
	_server_advertise.serverInfo["public"] = true
	
	_ui.broadcast_host_player_join()
	
################################################################
func _connection_closed():
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
func _server_disconnected():
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
################################################################
# network connection for client
func init_client():
	Network.connect("client_player_connected", self , "_client_player_connected")
	Network.connect("server_disconnected", self , "_server_disconnected")
	Network.connect("connection_closed", self ,"_connection_closed")
	
	var err = Network.connect_to_server(Global.client.ip, Global.client.port , {})
	if err != OK:
		return
	
func _client_player_connected(_player_network_unique_id : int, player : Dictionary):
	Global.client.network_unique_id = _player_network_unique_id
	_ui.broadcast_client_player_join(_player_network_unique_id)
	
################################################################
func _on_ui_on_exit_click():
	Network.disconnect_from_server()












