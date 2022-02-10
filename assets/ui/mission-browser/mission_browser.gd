extends Control

const ITEM = preload("res://assets/ui/mission-browser/item/item.tscn")
const ITEM_CONTRACT = preload("res://assets/ui/mission-browser/contract-item/contract_item.tscn")

signal accept_mission(_mission)
signal accept_contract(_contract)

onready var _mission_tab = $VBoxContainer/mission_tab
onready var _mission_item_holder = $VBoxContainer/mission_tab/VBoxContainer

onready var _contract_tab = $VBoxContainer/contract_tab
onready var _contract_item_holder = $VBoxContainer/contract_tab/VBoxContainer

func display_missions(_missions):
	clear_list(_mission_item_holder)
	
	for i in _missions:
		var item = ITEM.instance()
		item.mission = i
		item.connect("accept", self, "_accept_mission")
		_mission_item_holder.add_child(item)
		
func display_contracts(_contracts):
	clear_list(_contract_item_holder)
	
	for i in _contracts:
		var item = ITEM_CONTRACT.instance()
		item.contract = i
		item.connect("accept", self, "_accept_contract")
		_contract_item_holder.add_child(item)
		
func _accept_mission(mission):
	emit_signal("accept_mission", mission)
	
func _accept_contract(contract):
	emit_signal("accept_contract", contract)
	
func clear_list(_holder):
	for i in _holder.get_children():
		_holder.remove_child(i)

func hide_all():
	_mission_tab.visible = false
	_contract_tab.visible = false
	
func _on_exit_pressed():
	visible = false

func _on_btn_mission_pressed():
	hide_all()
	_mission_tab.visible = true

func _on_btn_contract_pressed():
	hide_all()
	_contract_tab.visible = true







