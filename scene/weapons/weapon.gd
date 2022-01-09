extends Node
class_name Weapon

const TYPE_UNGUIDED = "UNGUIDED"
const TYPE_GUIDED = "GUIDED"
const TYPE_LOCK_ON = "LOCKON"
const TYPE_CONTROLLED = "CONTROLLED"
const TYPE_UTILITY = "UTILITY"

const PLAYER_TEMPLATES = [
	{
		name = "20MM",
		damage = 10.0,
		speed = 15.0,
		type = TYPE_UNGUIDED,
		ammo_scene = "res://scene/weapons/un-guided/cannon-ball/cannon_ball.tscn",
		min_range = 0.0,
		max_range = 60.0,
		ammo = 250,
		max_ammo = 250
	},
	{
		name = "Bomb",
		damage = 40.0,
		speed = 3.0,
		type = TYPE_UNGUIDED,
		ammo_scene = "res://scene/weapons/un-guided/bomb/bomb.tscn",
		min_range = 0.0,
		max_range = 900.0,
		ammo = 50,
		max_ammo = 50
	},
	{
		name = "H-S-M",
		damage = 10.0,
		speed = 5.0,
		type = TYPE_LOCK_ON,
		ammo_scene = "res://scene/weapons/lock-on/lock-on-missile/lock_on_missile.tscn",
		min_range = 0.0,
		max_range = 70.0,
		ammo = 15,
		max_ammo = 15
	},
	{
		name = "Fighter",
		damage = 1.0,
		speed = 6.0,
		ammo_restock = 1,
		ranges = 10.0,
		fuel = 45.0,
		accuracy = 0.4,
		hp = 5,
		max_hp = 5,
		type = TYPE_CONTROLLED,
		ammo_scene = "res://scene/weapons/controlled/biplane/biplane.tscn",
		min_range = 5.0,
		max_range = 120.0,
		ammo = 2,
		max_ammo = 2
	},
]

const TEMPLATES = [
	{
		name = "20MM",
		damage = 10.0,
		speed = 15.0,
		type = TYPE_UNGUIDED,
		ammo_scene = "res://scene/weapons/un-guided/cannon-ball/cannon_ball.tscn",
		min_range = 0.0,
		max_range = 60.0,
		ammo = 250,
		max_ammo = 250
	},
#	{
#		name = "Bomb",
#		damage = 40.0,
#		speed = 3.0,
#		type = TYPE_UNGUIDED,
#		ammo_scene = "res://scene/weapons/un-guided/bomb/bomb.tscn",
#		min_range = 0.0,
#		max_range = 900.0,
#		ammo = 50,
#		max_ammo = 50
#	},
	{
		name = "G-M",
		damage = 20.0,
		speed = 5.0,
		type = TYPE_GUIDED,
		ammo_scene = "res://scene/weapons/guided/guided-missile/guided_missile.tscn",
		min_range = 10.0,
		max_range = 80.0,
		ammo = 25,
		max_ammo = 25
	},
	{
		name = "H-S-M",
		damage = 10.0,
		speed = 5.0,
		type = TYPE_LOCK_ON,
		ammo_scene = "res://scene/weapons/lock-on/lock-on-missile/lock_on_missile.tscn",
		min_range = 0.0,
		max_range = 70.0,
		ammo = 15,
		max_ammo = 15
	},
	{
		name = "Fighter",
		damage = 1.0,
		speed = 6.0,
		ammo_restock = 1,
		ranges = 10.0,
		fuel = 45.0,
		accuracy = 0.4,
		hp = 5,
		max_hp = 5,
		type = TYPE_CONTROLLED,
		ammo_scene = "res://scene/weapons/controlled/biplane/biplane.tscn",
		min_range = 5.0,
		max_range = 120.0,
		ammo = 2,
		max_ammo = 2
	},
	{
		name = "A-Mine",
		damage = 35.0,
		speed = 0.0,
		type = TYPE_UNGUIDED,
		ammo_scene = "res://scene/weapons/un-guided/air-mine/air_mine.tscn",
		min_range = 0.0,
		max_range = 900.0,
		ammo = 5,
		max_ammo = 5
	},
#	{
#		name = "Repair",
#		hp = 50.0,
#		max_hp = 50.0,
#		cruise_speed = -0.6,
#		turn_speed = -0.3,
#		type = TYPE_UTILITY,
#		ammo = 1,
#		max_ammo = 1
#	},
#	{
#		name = "Overdrive",
#		hp = -25.0,
#		max_hp = -25.0,
#		cruise_speed = 2.0,
#		turn_speed = 1.0,
#		type = TYPE_UTILITY,
#		ammo = 1,
#		max_ammo = 1
#	}
]
