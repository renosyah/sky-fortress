extends Control

onready var _operation_name = $ScrollContainer/HBoxContainer/VBoxContainer/operation_name
onready var _operation_season = $ScrollContainer/HBoxContainer/VBoxContainer/operation_season
onready var _operation_description = $ScrollContainer/HBoxContainer/VBoxContainer/operation_description
onready var _operation_reward = $ScrollContainer/HBoxContainer/VBoxContainer/operation_reward

func show_mission_info(_mission_data):
	_operation_name.text = _mission_data.name
	_operation_season.text = "Season : " + _mission_data.season
	_operation_description.text = "\"" + _mission_data.description + "\""
	_operation_reward.text = "Max Reward : $" + str(Missions.get_total_reward(_mission_data))
	
	
