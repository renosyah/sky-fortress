extends Control

signal on_close
signal on_contract_completed(_contract)
signal on_abort

onready var _operation_name = $VBoxContainer/Panel/HBoxContainer/CenterContainer2/VBoxContainer/Label

onready var _objective_page = $VBoxContainer/HBoxContainer2/HBoxContainer/objective_page
onready var _contract_page = $VBoxContainer/HBoxContainer2/HBoxContainer/contract_page
onready var _team_status_page = $VBoxContainer/HBoxContainer2/HBoxContainer/team_status_page
onready var _score_page = $VBoxContainer/HBoxContainer2/HBoxContainer/score_board_page
onready var _menu_page = $VBoxContainer/HBoxContainer2/HBoxContainer/menu_page

onready var _operation_level = $VBoxContainer/HBoxContainer2/HBoxContainer/objective_page/VBoxContainer/level
onready var _operation_progress = $VBoxContainer/HBoxContainer2/HBoxContainer/objective_page/VBoxContainer/progress
onready var _operation_message = $VBoxContainer/HBoxContainer2/HBoxContainer/objective_page/VBoxContainer/message

onready var _fleet_status_holder = $VBoxContainer/HBoxContainer2/HBoxContainer/team_status_page/VBoxContainer
onready var _scoreboard_holder = $VBoxContainer/HBoxContainer2/HBoxContainer/score_board_page/VBoxContainer
onready var _contract_holder = $VBoxContainer/HBoxContainer2/HBoxContainer/contract_page/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func hide_all():
	_objective_page.visible = false
	_team_status_page.visible = false
	_score_page.visible = false
	_menu_page.visible = false
	_contract_page.visible = false
	
func update_objective(operation : Dictionary, current_mission : Dictionary):
	_operation_name.text = operation.name
	
	if current_mission.empty():
		return
		
	_operation_level.text = "- Mission Progress (" + str(current_mission.level) + " / " + str(operation.total_level) + ")"
	_operation_progress.text = "- Destroy Enemy (" + str(current_mission.hostile_total - current_mission.hostile_left) + " / " + str(current_mission.hostile_total) + ")"
	_operation_message.text = "- Survive!"
	
func display_fleet_status(_players):
	for i in _fleet_status_holder.get_children():
		_fleet_status_holder.remove_child(i)
		
	for i in _players:
		var item = preload("res://assets/ui/objective_tab/fleet-status-item/fleet_status_item.tscn").instance()
		item.player_id = i.player_id
		item.player_name = i.player_name
		item.player_ship_name = i.player_ship_name
		item.player_ship_icon = i.player_ship_icon
		item.hp = i.hp
		item.max_hp = i.max_hp
		_fleet_status_holder.add_child(item)
		
		
func on_fleet_on_take_damage(player, damage, hp):
	if _fleet_status_holder.get_children().empty():
		return
		
	for i in _fleet_status_holder.get_children():
		if i.player_id == player.owner_id:
			i.update_bar(hp, player.max_hp)
	
	
func display_scoreboard(_players):
	for i in _scoreboard_holder.get_children():
		_scoreboard_holder.remove_child(i)
		
	for i in _players:
		var item = preload("res://assets/ui/objective_tab/score-board-item/score_board_item.tscn").instance()
		item.player_id = i.player_id
		item.player_name = i.player_name
		item.player_ship_name = i.player_ship_name
		item.player_ship_icon = i.player_ship_icon
		item.kill_count = 0
		item.cash_count = 0
		_scoreboard_holder.add_child(item)
		
func update_scoreboard(_player_id : String, kill_add, cash_add : int = 0):
	for i in _scoreboard_holder.get_children():
		if i.player_id == _player_id:
			i.update_score(kill_add, cash_add)
	
func display_active_contract():
	var _contract = {}
	for i in Global.contract_list:
		if i.is_selected:
			_contract = i
			break
			
	if _contract.empty():
		return
			
	for i in _contract_holder.get_children():
		_contract_holder.remove_child(i)
		
	var item = preload("res://assets/ui/mission-browser/contract-item/contract_item.tscn").instance()
	item.contract = _contract
	item.show_button = false
	_contract_holder.add_child(item)
	
func update_active_contract(_player_id : String, enemy_destroy : int = 0, airship_destroy : int = 0, fort_destroy : int = 0):
	if _player_id != Global.player_data.id:
		return
		
	var _contract = {}
	for i in Global.contract_list:
		if i.is_selected:
			_contract = i
			break
			
	if _contract.empty():
		return
		
	if _contract.status == Missions.CONTRACT_SUCCESS:
		return
		
	for sub in _contract.subs:
		if sub.status == Missions.CONTRACT_SUCCESS:
			continue
			
		if sub.contract_type == Missions.CONTRACT_TYPE_KILL:
			sub.progress += enemy_destroy
			
		elif sub.contract_type == Missions.CONTRACT_TYPE_BOMBING:
			sub.progress += fort_destroy
			
		elif sub.contract_type == Missions.CONTRACT_TYPE_SHOTTING_DOWN:
			sub.progress += airship_destroy
			
		sub.status = Missions.CONTRACT_SUCCESS if sub.progress >= sub.goal else Missions.CONTRACT_NOT_COMMIT
		break
		
	var is_sub_completed = true
	var reward_from_contract = 0
	
	for sub in _contract.subs:
		if sub.status != Missions.CONTRACT_SUCCESS:
			is_sub_completed = false
			break

	if is_sub_completed:
		_contract.status = Missions.CONTRACT_SUCCESS
		reward_from_contract = _contract.reward
		
		Global.player_data.cash += reward_from_contract
		Global.save_player_data()
		
		emit_signal("on_contract_completed", _contract)
		
	Global.save_player_contracts()
	display_active_contract()
	
func _on_button_close_pressed():
	emit_signal("on_close")
	
func _on_btn_objective_pressed():
	hide_all()
	_objective_page.visible = true

func _on_btn_team_status_pressed():
	hide_all()
	_team_status_page.visible = true

func _on_btn_score_board_pressed():
	hide_all()
	_score_page.visible = true

func _on_btn_menu_pressed():
	hide_all()
	_menu_page.visible = true
	
func _on_btn_contract_pressed():
	hide_all()
	_contract_page.visible = true
	display_active_contract()
	
func _on_abort_button_pressed():
	emit_signal("on_abort")














