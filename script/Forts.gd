extends Node
class_name Forts

const FORT_LIST = [
	{
		id = "f-1",
		name = "Basic AA",
		scene = "res://scene/fort/aa-instalation/aa_instalation.tscn", 
		owner_id = "",
		player_name = "",
		side = "",
		max_hp = 500,
		hp = 500,
		firing_delay = 0.4,
		weapons = Weapons.AA_FORT_TEMPLATE,
		skin = ""
	},
	{
		id = "f-2",
		name = "Airstrip",
		scene = "res://scene/fort/airstrip/airstrip.tscn", 
		owner_id = "",
		player_name = "",
		side = "",
		max_hp = 250,
		hp = 250,
		firing_delay = 9.0,
		weapons = Weapons.AIRSTRIP_FORT_TEMPLATE,
		skin = ""
	}
]
