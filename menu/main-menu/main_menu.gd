extends Node

onready var _terrain = $terrain
onready var _ship_holder = $ship_holder

func _ready():
	_terrain.season = "summer"
	_terrain.blank_map = true
	_terrain.generate()
	display_selected_ship(Global.selected_ship)
	
func display_selected_ship(ship_data):
	for i in _ship_holder.get_children():
		_ship_holder.remove_child(i)
	
	var ship = load(ship_data.scene).instance()
	_ship_holder.add_child(ship)
	ship.destroyed = true
	ship.set_data(ship_data)
	
func _on_ui_on_list_panel_on_item_press(ship_data):
	Global.selected_ship = ship_data.duplicate()
	Global.selected_ship.owner_id = Global.player_data.id
	Global.selected_ship.player_name = Global.player_data.name
	Global.save_player_selected_ship(Global.selected_ship)
	display_selected_ship(Global.selected_ship)



