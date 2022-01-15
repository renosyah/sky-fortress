extends Control

signal on_exit_click()
signal on_battle_click()

onready var _battle_btn_layout = $CanvasLayer/Control/VBoxContainer/PanelContainer/HBoxContainer/CenterContainer
onready var _chat_input = $CanvasLayer/Control/VBoxContainer/HBoxContainer/chat/VBoxContainer/HBoxContainer/input_chat
onready var _chat_list = $CanvasLayer/Control/VBoxContainer/HBoxContainer/chat/VBoxContainer/ScrollContainer/chat_list
onready var _player_slots = $CanvasLayer/Control/VBoxContainer/HBoxContainer/player_slot/VBoxContainer/ScrollContainer/player_slots
onready var _exit_timer = $exit_timer

################################################################
# sync lobby
var player_joined : Array
remote func _request_player_joined(from : int):
	rpc_id(from, "_response_player_joined", player_joined)
	
remote func _response_player_joined(data : Array):
	data.append(Global.selected_ship)
	rpc("_update_player_joined", data)
	
remotesync func _update_player_joined(data : Array):
	player_joined = data
	fill_player_slot()
	
remotesync func _send_chat(_message, _from):
	var chat_item = preload("res://menu/lobby-menu/ui/chat_item.tscn").instance()
	chat_item.text = "("+ _from +") : " + _message
	_chat_list.add_child(chat_item)
	
remotesync func _battle():
	Global.mp_battle_data = player_joined
	
	if Global.mode == Global.MODE_HOST:
		get_tree().change_scene("res://map/multi-player/host/battle.tscn")
	else:
		get_tree().change_scene("res://map/multi-player/client/battle.tscn")
		
		
################################################################
# Called when the node enters the scene tree for the first time.
func _ready():
	_battle_btn_layout.visible = (Global.mode == Global.MODE_HOST)
	
func fill_player_slot():
	for i in _player_slots.get_children():
		_player_slots.remove_child(i)
	
	for i in player_joined:
		var item = preload("res://assets/ui/list-panel/item/item.tscn").instance()
		item.data = { name = i.name, icon = i.icon}
		_player_slots.add_child(item)
		item.display_item()

func _on_exit_pressed():
	player_joined.erase(Global.selected_ship)
	rpc("_update_player_joined", player_joined)
	rpc("_send_chat", "has Left!", Global.player_data.name)
	_exit_timer.start()
	
func _on_exit_timer_timeout():
	emit_signal("on_exit_click")
	
func _on_battle_button_pressed():
	rpc("_battle")
	
func _on_send_pressed():
	rpc("_send_chat", _chat_input.text, Global.player_data.name)
	_chat_input.text = ""
	










