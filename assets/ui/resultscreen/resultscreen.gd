extends Control

const WIN_COLOR = Color(0.062745, 0.827451, 0)
const LOSE_COLOR = Color(1, 0.109375, 0.109375)

signal on_exit

onready var _condition = $VBoxContainer/Panel/HBoxContainer/CenterContainer2/VBoxContainer/condition
onready var _message = $VBoxContainer/CenterContainer/VBoxContainer/message

onready var _airship_destroy = $VBoxContainer/CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer/airship_destroy
onready var _fort_destroy = $VBoxContainer/CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer2/fort_destroy
onready var _cash_collected = $VBoxContainer/CenterContainer/VBoxContainer/VBoxContainer2/HBoxContainer/cash_collected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func display_mission_result(_result : Dictionary):
	_condition.modulate = WIN_COLOR if _result.is_win else LOSE_COLOR
	_condition.text = "Victory!" if _result.is_win else "Defeat!"
	
	_message.text = "All enemy forces has been Destroyed!" if _result.is_win else "All Friendly Forces has been destroyed!"
	_airship_destroy.text = str(_result.total_airship_destroyed)
	_fort_destroy.text = str(_result.total_fort_destroyed)
	_cash_collected.text = "$" + str(_result.total_cash_collected)
	
func _on_exit_pressed():
	emit_signal("on_exit")
