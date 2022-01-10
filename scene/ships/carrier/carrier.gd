extends "res://scene/ships/cruiser/cruiser.gd"

func _ready():
	._ready()
	max_hp = 150
	hp = 150
	cruise_speed = 2.0
	turn_speed = 0.5
	update_hp_bar()
