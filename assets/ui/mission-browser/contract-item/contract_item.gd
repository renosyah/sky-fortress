extends Control

const ITEM = preload("res://assets/ui/mission-browser/contract-item/sub-item/sub_item.tscn")

const BTN_DEFAULT = Color(0, 0.592157, 0.035294)
const BTN_DISABLE = Color(0.355469, 0.355469, 0.355469)

signal accept(_contract)

onready var _issue_by = $Panel/HBoxContainer/VBoxContainer/issue_by
onready var _description = $Panel/HBoxContainer/VBoxContainer/description
onready var _sub_holder = $Panel/HBoxContainer/VBoxContainer/VBoxContainer
onready var _reward = $Panel/HBoxContainer/VBoxContainer2/reward

onready var _accept_button = $Panel/HBoxContainer/VBoxContainer2/button/btn
onready var _accept_button_holder = $Panel/HBoxContainer/VBoxContainer2/button
onready var _label = $Panel/HBoxContainer/VBoxContainer2/button/Label

var contract = {}
var show_button = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if contract.empty():
		return
	
	_accept_button.disabled = contract.is_selected
	_accept_button.modulate = BTN_DISABLE if contract.is_selected else BTN_DEFAULT
	_accept_button_holder.visible = contract.status == Missions.OPERATION_NOT_COMMIT
	_accept_button_holder.visible = show_button
	_label.text = "Active" if contract.is_selected else "Set Active"
	
	_issue_by.text = contract.name
	_description.text = "\"" + contract.description + "\""
	_reward.text = "Reward : $" + str(contract.reward)
	
	for i in _sub_holder.get_children():
		_sub_holder.remove_child(i)
		
	for i in contract.subs:
		var item = ITEM.instance()
		item.sub_contract = i
		_sub_holder.add_child(item)
	
func _on_btn_pressed():
	emit_signal("accept", contract)








