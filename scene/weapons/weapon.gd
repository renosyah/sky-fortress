extends Node
class_name Weapon

const TYPE_UNGUIDED = "UNGUIDED"
const TYPE_GUIDED = "GUIDED"
const TYPE_LOCK_ON = "LOCKON"
const TYPE_CONTROLLED = "CONTROLLED"
const TYPE_UTILITY = "UTILITY"

const DAMAGE_MULTIPLIER = 0.25

static func get_damage_mult(damage) -> float:
	var r_dmg = DAMAGE_MULTIPLIER * damage
	return rand_range(damage - r_dmg, damage + r_dmg)

const HEAT_SEAKING_TORPEDO = {
	id = "",
	name = "H-S-M",
	icon = "res://assets/ui/icon/weapon/heat_seeking.png",
	cool_down = 3,
	damage = 10.0,
	speed = 5.0,
	type = TYPE_LOCK_ON,
	ammo_scene = "res://scene/weapons/lock-on/lock-on-missile/lock_on_missile.tscn",
	min_range = 0.0,
	max_range = 70.0,
	ammo = 45,
	max_ammo = 45,
	can_fire = false
}
const AUTO_CANNON = {
	id = "",
	name = "40MM",
	icon = "res://assets/ui/icon/weapon/40mm.png",
	cool_down = 0.3,
	damage = 10.0,
	speed = 15.0,
	type = TYPE_UNGUIDED,
	ammo_scene = "res://scene/weapons/un-guided/cannon-ball/cannon_ball.tscn",
	min_range = 0.0,
	max_range = 40.0,
	ammo = 450,
	max_ammo = 450,
	can_fire = false
}
const FIGHTER = {
	id = "",
	name = "Fighter",
	icon = "res://assets/ui/icon/weapon/fighter.png",
	cool_down = 4,
	damage = 1.0,
	speed = 5.2,
	ammo_restock = 1,
	ranges = 10.0,
	fuel = 45.0,
	accuracy = 0.4,
	hp = 5,
	max_hp = 5,
	type = TYPE_CONTROLLED,
	ammo_scene = "res://scene/weapons/controlled/biplane/biplane.tscn",
	min_range = 5.0,
	max_range = 80.0,
	ammo = 4,
	max_ammo = 4,
	can_fire = false
}
const BOMBER = {
	id = "",
	name = "Bomber",
	icon = "res://assets/ui/icon/weapon/bomber.png",
	cool_down = 4.6,
	damage = 55.0,
	speed = 4.0,
	ammo_restock = 1,
	ranges = 10.0,
	fuel = 45.0,
	accuracy = 0.4,
	hp = 8,
	max_hp = 8,
	type = TYPE_CONTROLLED,
	ammo_scene = "res://scene/weapons/controlled/biplane-bomber/biplane_bomber.tscn",
	min_range = 5.0,
	max_range = 80.0,
	ammo = 2,
	max_ammo = 2,
	can_fire = false
}
const GUIDED_TORPEDO = {
	id = "",
	name = "G-M",
	icon = "res://assets/ui/icon/weapon/guided.png",
	cool_down = 3.6,
	damage = 20.0,
	speed = 5.0,
	type = TYPE_GUIDED,
	ammo_scene = "res://scene/weapons/guided/guided-missile/guided_missile.tscn",
	min_range = 10.0,
	max_range = 70.0,
	ammo = 25,
	max_ammo = 25,
	can_fire = true
}
const AIR_MINE = {
	id = "",
	name = "A-Mine",
	icon = "res://assets/ui/icon/weapon/air_mine.png",
	cool_down = 5.2,
	damage = 35.0,
	speed = 1.4,
	type = TYPE_UNGUIDED,
	ammo_scene = "res://scene/weapons/un-guided/air-mine/air_mine.tscn",
	min_range = 0.0,
	max_range = 900.0,
	ammo = 5,
	max_ammo = 5,
	can_fire = true
}
const BOMB = {
	id = "",
	name = "Bomb",
	icon = "res://assets/ui/icon/weapon/bomb.png",
	cool_down = 0.8,
	damage = 40.0,
	speed = 3.0,
	type = TYPE_UNGUIDED,
	ammo_scene = "res://scene/weapons/un-guided/bomb/bomb.tscn",
	min_range = 0.0,
	max_range = 900.0,
	ammo = 50,
	max_ammo = 50,
	can_fire = true
}








const CRUISER_TEMPLATES = [
	HEAT_SEAKING_TORPEDO,
	AUTO_CANNON
]
const CARRIER_TEMPLATES = [
	FIGHTER,
	BOMBER,
	HEAT_SEAKING_TORPEDO,
	AUTO_CANNON
]
const AA_FORT_TEMPLATE = [
	AUTO_CANNON,
]
const BOMBER_TEMPLATES = [
	GUIDED_TORPEDO,
	BOMB,
	AIR_MINE,
	AUTO_CANNON,
]



const UNUSED = [
	{
		name = "Repair",
		hp = 50.0,
		max_hp = 50.0,
		cruise_speed = -0.6,
		turn_speed = -0.3,
		type = TYPE_UTILITY,
		ammo = 1,
		max_ammo = 1
	},
	{
		name = "Overdrive",
		hp = -25.0,
		max_hp = -25.0,
		cruise_speed = 2.0,
		turn_speed = 1.0,
		type = TYPE_UTILITY,
		ammo = 1,
		max_ammo = 1
	}
]
