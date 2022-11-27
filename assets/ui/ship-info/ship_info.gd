extends Control

onready var _description = $ScrollContainer/HBoxContainer/VBoxContainer/desc
onready var _survival_bar = $ScrollContainer/HBoxContainer/VBoxContainer/hp/bar
onready var _mobility_bar = $ScrollContainer/HBoxContainer/VBoxContainer/speed/bar
onready var _firepower_bar = $ScrollContainer/HBoxContainer/VBoxContainer/firepower/bar

func show_ship_info(_ship_data):
	_description.text = _ship_data.description
	_survival_bar.show_label(false)
	_survival_bar.update_bar(_ship_data.max_hp,_ship_data.max_hp + 500.0)
	
	_mobility_bar.show_label(false)
	_mobility_bar.update_bar(_ship_data.cruise_speed, 5.0)
	
	_firepower_bar.show_label(false)
	_firepower_bar.update_bar(_ship_data.weapons.size(), 4)
	
	
