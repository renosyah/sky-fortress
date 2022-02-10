extends Control

signal on_list_panel_on_item_press(ship_data)
signal on_name_input(_name)

onready var _ship_label = $CanvasLayer/Control/VBoxContainer/HBoxContainer/VBoxContainer/Label
onready var _ship_condition_text = $CanvasLayer/Control/VBoxContainer/HBoxContainer/VBoxContainer/Control/condition
onready var _list_ship = $CanvasLayer/Control/VBoxContainer/PanelContainer2/list_panel
onready var _weapon_list = $CanvasLayer/Control/VBoxContainer/HBoxContainer/VBoxContainer/weapon_list
onready var _server_browser = $CanvasLayer/Control/server_browser

onready var _input_name_window = $CanvasLayer/Control/input_name
onready var _player_name = $CanvasLayer/Control/VBoxContainer/PanelContainer/HBoxContainer/MarginContainer4/name_button/Label
onready var _cash = $CanvasLayer/Control/VBoxContainer/PanelContainer/HBoxContainer/MarginContainer3/name_button2/cash

onready var _battle_result = $CanvasLayer/Control/battle_result
onready var _cash_loot = $CanvasLayer/Control/battle_result/Panel/VBoxContainer/HBoxContainer2/cash

onready var _exeption_message = $CanvasLayer/Control/exception_message
onready var _exeption_message_label = $CanvasLayer/Control/exception_message/Panel/VBoxContainer/HBoxContainer2/message

onready var _ship_info = $CanvasLayer/Control/VBoxContainer/HBoxContainer/Control2/ship_info
onready var _mission_info = $CanvasLayer/Control/VBoxContainer/HBoxContainer/Control/mission_info

onready var _mission_browser = $CanvasLayer/Control/mission_browser
onready var _shop_browser = $CanvasLayer/Control/shop

# Called when the node enters the scene tree for the first time.
func _ready():
	_list_ship.datas = Global.ship_list
	_list_ship.update_list()
	
	_weapon_list.datas = Global.selected_ship.weapons
	_weapon_list.clickable = false
	_weapon_list.update_list()
	
	_ship_label.text = Global.selected_ship.name
	_player_name.text = Global.player_data.name
	
	grab_battle_result()
	
	_exeption_message.visible = (Global.mp_exception_message != "")
	_exeption_message_label.text = Global.mp_exception_message
	
func grab_battle_result():
	var reward_from_loot = 0
	
	if Global.mp_battle_result.has("cash"):
		reward_from_loot = Global.mp_battle_result.cash
		
	if not Global.mp_battle_result.empty():
		_cash_loot.text = "$ " + str(reward_from_loot)
		_battle_result.visible = true
		
	_cash.text = "$" + str(Global.player_data.cash)
		
func show_ship_condition_message(_text="", show=true):
	_ship_condition_text.text = _text
	_ship_condition_text.visible = show
	
func show_ship_info(_ship_data):
	if _ship_data.empty():
		_ship_info.visible = false
		return
		
	_ship_info.visible = true
	_ship_info.show_ship_info(_ship_data)
	
func show_mission_info(_mission_data):
	if _mission_data.empty():
		_mission_info.visible = false
		return
		
	_mission_info.visible = true
	_mission_info.show_mission_info(_mission_data)
	
func _on_host_pressed():
	if not Global.is_ship_ok():
		_exeption_message.visible = true
		_exeption_message_label.text = "Repair Required!"
		return
		
	if Global.selected_mission.empty():
		_exeption_message.visible = true
		_exeption_message_label.text = "Mission not Selected!"
		return
		
	if Global.selected_mission.status != Missions.OPERATION_NOT_COMMIT:
		_on_mission_browser_accept_mission(Missions.generate_operation(Missions.DIFFICULTIES[randi() % Missions.DIFFICULTIES.size()]))
		
	# only host player can control what mission it takes
	Global.mode = Global.MODE_HOST
	get_tree().change_scene("res://menu/lobby-menu/lobby_menu.tscn")
	
func _on_join_pressed():
	if not Global.is_ship_ok():
		_exeption_message.visible = true
		_exeption_message_label.text = "Repair Required!"
		return
		
	_server_browser.visible = true
	_server_browser.clear_list()
	_server_browser.start_finding()
	
func _on_battle_button_pressed():
	if not Global.is_ship_ok():
		_exeption_message.visible = true
		_exeption_message_label.text = "Repair Required!"
		return
		
	if Global.selected_mission.empty():
		_exeption_message.visible = true
		_exeption_message_label.text = "Mission not Selected!"
		return
		
	if Global.selected_mission.status != Missions.OPERATION_NOT_COMMIT:
		_on_mission_browser_accept_mission(Missions.generate_operation(Missions.DIFFICULTIES[randi() % Missions.DIFFICULTIES.size()]))
		
	Network.connect("server_player_connected", self ,"_solo_player_connected")
	
	var err = Network.create_server(Global.server.max_player, Global.server.port , {})
	if err != OK:
		return
	
func _solo_player_connected(_player_network_unique_id : int, _player : Dictionary):
	Global.mode = Global.MODE_HOST
	Global.mp_players_data = [Global.selected_ship]
	get_tree().change_scene("res://map/multi-player/host/battle.tscn")
	
	
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
	Global.save_player_data()
	
	Global.apply_ship_ownership()
	Global.apply_ships_ownership()
	
	_player_name.text = " " + _name + " "
	_input_name_window.visible = false
	
func _on_change_player_name_pressed():
	_input_name_window.visible = true
	
func _on_receive_reward_confirm_pressed():
	Global.mp_battle_result = {}
	_battle_result.visible = false
	
func _on_close_exeption_message_pressed():
	Global.mp_exception_message = ""
	_exeption_message.visible = false
	
func _on_shop_button_pressed():
	_shop_browser.make_ready()
	_shop_browser.visible = true
	
func _on_shop_on_repaired(_ok):
	if not _ok:
		_exeption_message.visible = true
		_exeption_message_label.text = "Insufficient funds!"
		return
		
	_cash.text = "$" + str(Global.player_data.cash)
	show_ship_condition_message("Repair Required!", not Global.is_ship_ok())
	
func _on_shop_on_resupply(_ok):
	if not _ok:
		_exeption_message.visible = true
		_exeption_message_label.text = "Insufficient funds!"
		return
		
	_cash.text = "$" + str(Global.player_data.cash)
	_on_list_panel_on_item_press(Global.selected_ship)
	
func _on_mission_button_pressed():
	_mission_browser.display_missions(Global.mission_list)
	_mission_browser.display_contracts(Global.contract_list)
	_mission_browser.visible = true
	
func _on_mission_browser_accept_mission(_mission):
	Global.selected_mission = _mission
	show_mission_info(Global.selected_mission)
	
	for i in Global.mission_list:
		i.is_selected = false
		
	_mission.is_selected = true
	_mission_browser.display_missions(Global.mission_list)
	
	Global.save_player_selected_mission()
	
	_mission_browser.visible = false

func _on_mission_browser_accept_contract(_contract):
	for i in Global.contract_list:
		i.is_selected = false
	
	_contract.is_selected = true
	_mission_browser.display_contracts(Global.contract_list)
	
	Global.save_player_contracts()


























