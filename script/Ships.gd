extends Node
class_name Ships

const SHIP_LIST = [
	{
		id = "s-1",
		name = "Carrier",
		class_type = "Carrier",
		description = "Airtship with landing pad on top is purposely build to launch and retrieve aircraft from the sky, this type of airship is efective to targeting and hit enemy from long range",
		icon = "res://scene/ships/carrier/icon.png",
		scene = "res://scene/ships/carrier/carrier.tscn", 
		owner_id = "",
		player_name = "",
		side = "",
		max_hp = 150,
		hp = 150,
		cruise_speed = 2.0,
		turn_speed = 0.5,
		weapons = [Weapons.FIGHTER, Weapons.INTERCEPTOR, Weapons.BOMBER, Weapons.AUTO_CANNON],
		skin = ""
	},
	{
		id = "s-2",
		name = "Bomber",
		class_type = "Bomber",
		description = "this behemoth airtship have specialist weapon for air target and ground target only, with big size this type airship is most durrable from any other class",
		icon = "res://scene/ships/bomber/icon.png",
		scene = "res://scene/ships/bomber/bomber.tscn", 
		owner_id = "",
		player_name = "",
		side = "",
		max_hp = 250,
		hp = 250,
		cruise_speed = 3.0,
		turn_speed = 1.0,
		weapons = [Weapons.GUIDED_TORPEDO,Weapons.BOMB,Weapons.AIR_MINE,Weapons.AUTO_CANNON],
		skin = ""
	},
	{
		id = "s-3",
		name = "Cruiser",
		class_type = "Cruiser",
		description = "nimble yet vulnerable body with weak armament, but in number this type class can easily adapt to any combat",
		icon = "res://scene/ships/cruiser/icon.png",
		scene = "res://scene/ships/cruiser/cruiser.tscn", 
		owner_id = "",
		player_name = "",
		side = "",
		max_hp = 100,
		hp = 100,
		cruise_speed = 4.0,
		turn_speed = 1.5,
		weapons = [Weapons.HEAT_SEAKING_TORPEDO, Weapons.AUTO_CANNON],
		skin = ""
	}
]
