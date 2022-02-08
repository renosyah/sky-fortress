extends Control

const ITEM = preload("res://assets/ui/mission-browser/item/item.tscn")

signal accept_mission(_mission)

onready var _item_holder = $VBoxContainer/ScrollContainer/VBoxContainer
onready var _mission_list = $VBoxContainer/ScrollContainer
onready var _mission_empty = $VBoxContainer/Label

func display_missions(_missions):
	show_empty(_missions.empty())
	
	clear_list()
	for i in _missions:
		var item = ITEM.instance()
		item.mission = i
		item.connect("accept", self, "_accept")
		_item_holder.add_child(item)
	
func _accept(mission):
	emit_signal("accept_mission", mission)
	
func clear_list():
	for i in _item_holder.get_children():
		_item_holder.remove_child(i)
	
func show_empty(_show):
	_mission_empty.visible = _show
	_mission_list.visible = not _show
	
func _on_exit_pressed():
	visible = false
