extends Node

onready var _terrain = $terrain
onready var _ship_holder = $ship_holder
onready var _ui = $ui

func _ready():
	init_terrain()
	spawn_selected_ship(Global.selected_ship)
	_ui.show_mission_info(Global.selected_mission)
	
func init_terrain():
	_terrain.season = "summer"
	_terrain.blank_map = true
	_terrain.generate()
	
func spawn_selected_ship(ship_data):
	for i in _ship_holder.get_children(): 
		_ship_holder.remove_child(i)
	
	var ship = load(ship_data.scene).instance()
	_ship_holder.add_child(ship)
	ship.destroyed = true
	ship.set_data(ship_data)
	
	_ui.show_ship_info(ship_data)
	_ui.show_ship_condition_message("Repair Required!", not Global.is_ship_ok())
	
func _on_ui_on_list_panel_on_item_press(ship_data):
	if ship_data != Global.selected_ship:
		Global.selected_ship = ship_data
		Global.save_player_selected_ship()
		
	spawn_selected_ship(ship_data)




