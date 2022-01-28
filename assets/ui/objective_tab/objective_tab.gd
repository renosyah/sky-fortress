extends Control

signal on_close

onready var _operation_name = $VBoxContainer/Panel/HBoxContainer/CenterContainer2/VBoxContainer/Label
onready var _operation_level = $VBoxContainer/CenterContainer/VBoxContainer/level
onready var _operation_progress = $VBoxContainer/CenterContainer/VBoxContainer/progress
onready var _operation_message = $VBoxContainer/CenterContainer/VBoxContainer/message

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func update_objective(operation : Dictionary, current_mission : Dictionary):
	_operation_name.text = operation.name
	
	if current_mission.empty():
		return
		
	_operation_level.text = "- Mission Progress (" + str(current_mission.level) + " / " + str(operation.total_mission) + ")"
	_operation_progress.text = "- Destroy Enemy (" + str(current_mission.hostile_total - current_mission.hostile_left) + " / " + str(current_mission.hostile_total) + ")"
	_operation_message.text = "- Survive!"
	
func _on_close_pressed():
	emit_signal("on_close")
