extends Control

signal on_list_panel_on_item_press(ship_data)

onready var _ship_label = $CanvasLayer/Control/VBoxContainer/Label
onready var _list_ship = $CanvasLayer/Control/VBoxContainer/PanelContainer2/list_panel
onready var _weapon_list = $CanvasLayer/Control/VBoxContainer/weapon_list

# Called when the node enters the scene tree for the first time.
func _ready():
	_list_ship.datas = Ship.SHIP_LIST
	_list_ship.update_list()
	
	_weapon_list.datas = Global.selected_ship.weapons
	_weapon_list.clickable = false
	_weapon_list.update_list()
	
	_ship_label.text = Global.selected_ship.name


func _on_battle_button_pressed():
	get_tree().change_scene("res://map/test/test.tscn")


func _on_list_panel_on_item_press(data):
	_weapon_list.datas = data.weapons
	_weapon_list.update_list()
	
	_ship_label.text = data.name
	
	emit_signal("on_list_panel_on_item_press", data)
