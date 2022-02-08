extends Control

const BTN_DEFAULT = Color(0, 0.592157, 0.035294)
const BTN_DISABLE = Color(0.355469, 0.355469, 0.355469)

signal accept(_mission)

onready var _operation_name = $Panel/HBoxContainer/VBoxContainer/operation_name
onready var _difficulty = $Panel/HBoxContainer/VBoxContainer/difficulty
onready var _accept_button = $Panel/HBoxContainer/button/btn
onready var _accept_button_holder = $Panel/HBoxContainer/button

var mission = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	if mission.empty():
		return
		
	_accept_button.disabled = mission.is_selected
	_accept_button.modulate = BTN_DISABLE if mission.is_selected else BTN_DEFAULT
	_accept_button_holder.visible = mission.status == Missions.OPERATION_NOT_COMMIT
	
	_operation_name.text = mission.name
	_difficulty.text = "Difficulty : " + mission.difficulty
	
func _on_btn_pressed():
	emit_signal("accept", mission)
