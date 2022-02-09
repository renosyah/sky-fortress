extends Control

const WIN_COLOR = Color(0, 1, 0.439216)
const LOSE_COLOR = Color(1, 0.109375, 0.109375)

onready var _operation_name = $ScrollContainer/HBoxContainer/VBoxContainer/operation_name
onready var _operation_season = $ScrollContainer/HBoxContainer/VBoxContainer/operation_season
onready var _operation_description = $ScrollContainer/HBoxContainer/VBoxContainer/operation_description
onready var _operation_reward = $ScrollContainer/HBoxContainer/VBoxContainer/operation_reward
onready var _status = $status

func show_mission_info(_mission_data):
	_operation_name.text = _mission_data.name
	_operation_season.text = "Season : " + _mission_data.season
	_operation_description.text = "\"" + _mission_data.description + "\""
	_operation_reward.text = "Reward : $" + str(Missions.get_total_reward(_mission_data))
	_status.visible = _mission_data.status != Missions.OPERATION_NOT_COMMIT
	_status.text = "[Completed!]" if  _mission_data.status == Missions.OPERATION_SUCCESS else "[Failed!]"
	_status.modulate = WIN_COLOR if _mission_data.status == Missions.OPERATION_SUCCESS else LOSE_COLOR
	
