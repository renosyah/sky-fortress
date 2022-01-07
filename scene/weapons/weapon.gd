extends Node
class_name Weapon

const TYPE_UNGUIDED = "UNGUIDED"
const TYPE_GUIDED = "GUIDED"
const TYPE_LOCK_ON = "LOCKON"
const TYPE_CONTROLLED = "CONTROLLED"

const TEMPLATES = [
	{
		damage = 15.0,
		speed = 10.0,
		type = TYPE_UNGUIDED,
		ammo_scene = "res://scene/weapons/un-guided/cannon-ball/cannon_ball.tscn",
		min_range = 0.0,
		max_range = 20.0
	},
	{
		damage = 20.0,
		speed = 5.0,
		type = TYPE_GUIDED,
		ammo_scene = "res://scene/weapons/guided/guided-missile/guided_missile.tscn",
		min_range = 5.0,
		max_range = 50.0
	},
	{
		damage = 10.0,
		speed = 5.0,
		type = TYPE_LOCK_ON,
		ammo_scene = "res://scene/weapons/lock-on/lock-on-missile/lock_on_missile.tscn",
		min_range = 10.0,
		max_range = 80.0
	}
]
