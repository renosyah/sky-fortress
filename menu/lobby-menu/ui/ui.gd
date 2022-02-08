extends Control

signal on_exit_click()
signal on_battle_click()
signal on_player_joined_update()

onready var _battle_btn_layout = $CanvasLayer/Control/VBoxContainer/PanelContainer/HBoxContainer/CenterContainer
onready var _player_slots = $CanvasLayer/Control/VBoxContainer/HBoxContainer/player_slot/VBoxContainer/ScrollContainer/player_slots
onready var _chat = $CanvasLayer/Control/VBoxContainer/HBoxContainer/chat
onready var _exit_timer = $exit_timer

################################################################
# sync lobby
var player_joined : Array = []
	
remote func _request_append_player_joined(from : int, data : Dictionary):
	player_joined.append(data)
	rpc("_update_player_joined", player_joined)
	
remote func _request_erase_player_joined(data : Dictionary):
	for i in player_joined:
		if i.owner_id == data.owner_id:
			player_joined.erase(i)
			break
			
	rpc("_update_player_joined", player_joined)
	
remotesync func _update_player_joined(data : Array):
	if not get_tree().is_network_server():
		player_joined = data
	fill_player_slot()
	
remotesync func _battle():
	Global.mp_players_data = player_joined
	
	if Global.mode == Global.MODE_HOST:
		get_tree().change_scene("res://map/multi-player/host/battle.tscn")
	else:
		get_tree().change_scene("res://map/multi-player/client/battle.tscn")
		
		
################################################################
# Called when the node enters the scene tree for the first time.
func _ready():
	_battle_btn_layout.visible = (Global.mode == Global.MODE_HOST)
	
func broadcast_host_player_join():
	player_joined.append(Global.selected_ship)
	fill_player_slot()
	_chat.player_join()
	
func broadcast_client_player_join(_player_network_unique_id):
	rpc_id(Network.PLAYER_HOST_ID, "_request_append_player_joined", _player_network_unique_id, Global.selected_ship)
	_chat.player_join()
	
func fill_player_slot():
	for i in _player_slots.get_children():
		_player_slots.remove_child(i)
	
	for i in player_joined:
		var item = preload("res://assets/ui/list-panel/item/item.tscn").instance()
		item.data = { name = i.name, icon = i.icon}
		_player_slots.add_child(item)
		item.display_item()
		
	emit_signal("on_player_joined_update")
		
func _on_exit_pressed():
	if not get_tree().is_network_server():
		rpc_id(Network.PLAYER_HOST_ID ,"_request_erase_player_joined", Global.selected_ship)
		
	_chat.player_left()
	_exit_timer.start()
	
func _on_exit_timer_timeout():
	emit_signal("on_exit_click")
	
func _on_battle_button_pressed():
	rpc("_battle")
	







