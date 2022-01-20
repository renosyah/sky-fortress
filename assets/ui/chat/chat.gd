extends Control

signal on_message(_message, _from)

onready var _chat_list = $VBoxContainer/ScrollContainer/chat_list
onready var _chat_input = $VBoxContainer/HBoxContainer/input_chat

################################################################
# sync chat
remotesync func _send_chat(_message, _from):
	var chat_item = preload("res://assets/ui/chat/item/item.tscn").instance()
	chat_item.text = "("+ _from +") : " + _message
	_chat_list.add_child(chat_item)
	emit_signal("on_message", _message, _from)
	
################################################################
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func player_join():
	rpc("_send_chat", "has Join!", Global.player_data.name)
	
func player_left():
	rpc("_send_chat", "has Left!", Global.player_data.name)
	
func _on_send_pressed():
	if _chat_input.text == "":
		return
		
	rpc("_send_chat", _chat_input.text, Global.player_data.name)
	_chat_input.text = ""
