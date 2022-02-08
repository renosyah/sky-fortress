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
		firing_delay = 2.0,
		weapons = [Weapons.AUTO_CANNON],
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
		firing_delay = 12.0,
		weapons = [Weapons.FIGHTER],
		skin = ""
	},
	{
		id = "f-3",
		name = "Missile AA",
		scene = "res://scene/fort/aa-instalation/aa_instalation.tscn", 
		owner_id = "",
		player_name = "",
		side = "",
		max_hp = 450,
		hp = 45,
		firing_delay = 9.0,
		weapons = [Weapons.HEAT_SEAKING_TORPEDO],
		skin = ""
	},
		{
		id = "f-2",
		name = "Airbase",
		scene = "res://scene/fort/airbase/airbase.tscn", 
		owner_id = "",
		player_name = "",
		side = "",
		max_hp = 400,
		hp = 400,
		firing_delay = 14.0,
		weapons = [Weapons.FIGHTER, Weapons.INTERCEPTOR],
		skin = ""
	},
]
