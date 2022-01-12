extends Control

signal on_list_panel_on_item_press(ship_data)

onready var _list_ship = $CanvasLayer/Control/VBoxContainer/PanelContainer2/list_panel

# Called when the node enters the scene tree for the first time.
func _ready():
	_list_ship.datas = Ship.SHIP_LIST
	_list_ship.update_list()


func _on_battle_button_pressed():
	pass # Replace with function body.


func _on_list_panel_on_item_press(data):
	emit_signal("on_list_panel_on_item_press", data)
