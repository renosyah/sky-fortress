extends Node
class_name Ships

const SHIP_LIST = [
	{
		id = "s-1",
		name = "Carrier",
		icon = "res://scene/ships/carrier/icon.png",
		scene = "res://scene/ships/carrier/carrier.tscn", 
		owner_id = "",
		player_name = "",
		side = "",
		max_hp = 1500,
		hp = 1500,
		cruise_speed = 2.0,
		turn_speed = 0.5,
		weapons = Weapons.CARRIER_TEMPLATES,
		skin = ""
	},
	{
		id = "s-2",
		name = "Bomber",
		icon = "res://scene/ships/bomber/icon.png",
		scene = "res://scene/ships/bomber/bomber.tscn", 
		owner_id = "",
		player_name = "",
		side = "",
		max_hp = 2500,
		hp = 2500,
		cruise_speed = 3.0,
		turn_speed = 1.0,
		weapons = Weapons.BOMBER_TEMPLATES,
		skin = ""
	},
	{
		id = "s-3",
		name = "Cruiser",
		icon = "res://scene/ships/cruiser/icon.png",
		scene = "res://scene/ships/cruiser/cruiser.tscn", 
		owner_id = "",
		player_name = "",
		side = "",
		max_hp = 1000,
		hp = 1000,
		cruise_speed = 4.0,
		turn_speed = 1.5,
		weapons = Weapons.CRUISER_TEMPLATES,
		skin = ""
	}
	
]