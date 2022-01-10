extends "res://scene/ships/cruiser/cruiser.gd"

func _ready():
	._ready()
	max_hp = 250
	hp = 250
	cruise_speed = 3.0
	turn_speed = 1.0
	update_hp_bar()
