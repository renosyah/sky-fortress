extends Control

const WIN_COLOR = Color(0.062745, 0.827451, 0)
const LOSE_COLOR = Color(1, 0.109375, 0.109375)

signal on_exit

onready var _condition = $VBoxContainer/Panel/HBoxContainer/CenterContainer2/VBoxContainer/condition
onready var _message = $VBoxContainer/CenterContainer/VBoxContainer/message

onready var _airship_destroy = $VBoxContainer/CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer/airship_destroy
onready var _fort_destroy = $VBoxContainer/CenterContainer/VBoxContainer/VBoxContainer/HBoxContainer2/fort_destroy

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func display_mission_result(is_win : bool, total_airship_destroyed, total_fort_destroyed : int):
	_condition.modulate = WIN_COLOR if is_win else LOSE_COLOR
	_condition.text = "Victory!" if is_win else "Defeat!"
	
	_message.text = "All enemy forces has been Destroyed!" if is_win else "All Friendly Forces has been destroyed!"
	_airship_destroy.text = str(total_airship_destroyed)
	_fort_destroy.text = str(total_fort_destroyed)
	
func _on_exit_pressed():
	emit_signal("on_exit")
