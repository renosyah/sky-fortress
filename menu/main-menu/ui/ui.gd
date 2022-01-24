extends Control

signal on_list_panel_on_item_press(ship_data)
signal on_name_input(_name)

onready var _ship_label = $CanvasLayer/Control/VBoxContainer/HBoxContainer/VBoxContainer/Label
onready var _list_ship = $CanvasLayer/Control/VBoxContainer/PanelContainer2/list_panel
onready var _weapon_list = $CanvasLayer/Control/VBoxContainer/HBoxContainer/VBoxContainer/weapon_list
onready var _server_browser = $CanvasLayer/Control/server_browser

onready var _input_name_window = $CanvasLayer/Control/input_name
onready var _player_name = $CanvasLayer/Control/VBoxContainer/PanelContainer/HBoxContainer/name_button/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	_list_ship.datas = Global.ship_list
	_list_ship.update_list()
	
	_weapon_list.datas = Global.selected_ship.weapons
	_weapon_list.clickable = false
	_weapon_list.update_list()
	
	_ship_label.text = Global.selected_ship.name
	_player_name.text = Global.player_data.name
	
func _on_host_pressed():
	Global.mode = Global.MODE_HOST
	get_tree().change_scene("res://menu/lobby-menu/lobby_menu.tscn")
	
func _on_join_pressed():
	_server_browser.visible = true
	_server_browser.clear_list()
	_server_browser.start_finding()
	
func _on_battle_button_pressed():
	get_tree().change_scene("res://map/test/test.tscn")
	
func _on_list_panel_on_item_press(data):
	_weapon_list.datas = data.weapons
	_weapon_list.update_list()
	
	_ship_label.text = data.name
	
	emit_signal("on_list_panel_on_item_press", data)
	
func _on_server_browser_on_join(info):
	Global.mode = Global.MODE_JOIN
	Global.client = { ip = info["ip"], port = Network.DEFAULT_PORT }
	get_tree().change_scene("res://menu/lobby-menu/lobby_menu.tscn")
	
	
func _on_input_name_on_continue(_name, html_color):
	Global.player_data.name = _name
	Global.player_data.color = Color(html_color)
	Global.save_player_data(Global.player_data)
	_player_name.text = " " + _name + " "
	_input_name_window.visible = false
	
func _on_change_player_name_pressed():
	_input_name_window.visible = true
