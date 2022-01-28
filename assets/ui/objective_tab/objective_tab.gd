extends Control

signal on_close

onready var _operation_name = $VBoxContainer/Panel/CenterContainer2/VBoxContainer/Label
onready var _operation_level = $VBoxContainer/CenterContainer/VBoxContainer/level
onready var _operation_progress = $VBoxContainer/CenterContainer/VBoxContainer/progress

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func update_objective(operation : Dictionary, current_mission : Dictionary):
	_operation_name.text = operation.name
	
	if current_mission.empty():
		return
		
	_operation_level.text = "- Level " + str(current_mission.level) + " / " + str(operation.total_mission)
	_operation_progress.text = "- Enemy Destroyed " + str(current_mission.hostile_total - current_mission.hostile_left) + " / " + str(current_mission.hostile_total)
	
func _on_close_pressed():
	emit_signal("on_close")
