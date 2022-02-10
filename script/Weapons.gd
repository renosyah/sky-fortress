extends Node
class_name Weapons

const TYPE_UNGUIDED = "UNGUIDED"
const TYPE_GUIDED = "GUIDED"
const TYPE_LOCK_ON = "LOCKON"
const TYPE_CONTROLLED = "CONTROLLED"

const DAMAGE_MULTIPLIER = 0.25

static func get_damage_mult(damage) -> float:
	var r_dmg = DAMAGE_MULTIPLIER * damage
	return rand_range(damage - r_dmg, damage + r_dmg)
	
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
	hp = 20,
	max_hp = 20,
	type = TYPE_CONTROLLED,
	ammo_scene = "res://scene/weapons/controlled/fighter/biplane/biplane.tscn",
	min_range = 5.0,
	max_range = 90.0,
	ammo = 4,
	max_ammo = 4,
	ammo_cost = 120,
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
	hp = 15,
	max_hp = 15,
	type = TYPE_CONTROLLED,
	ammo_scene = "res://scene/weapons/controlled/tactical-bomber/biplane-bomber/biplane_bomber.tscn",
	min_range = 12.0,
	max_range = 120.0,
	ammo = 2,
	max_ammo = 2,
	ammo_cost = 180,
	can_fire = false
}
const INTERCEPTOR = {
	id = "",
	name = "Interceptor",
	icon = "res://assets/ui/icon/weapon/interceptor.png",
	cool_down = 4.3,
	damage = 35.0,
	speed = 4.6,
	ammo_restock = 1,
	ranges = 10.0,
	fuel = 45.0,
	accuracy = 0.4,
	hp = 20,
	max_hp = 20,
	type = TYPE_CONTROLLED,
	ammo_scene = "res://scene/weapons/controlled/interceptor/biplane-interceptor/biplane_interceptor.tscn",
	min_range = 10.0,
	max_range = 130.0,
	ammo = 2,
	max_ammo = 2,
	ammo_cost = 210,
	can_fire = false
}
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
	ammo_cost = 9,
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
	ammo_cost = 25,
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
	ammo_cost = 12,
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
	ammo_cost = 6,
	can_fire = true
}
const AUTO_CANNON = {
	id = "",
	name = "40MM",
	icon = "res://assets/ui/icon/weapon/40mm.png",
	cool_down = 0.3,
	damage = 10.0,
	speed = 15.0,
	type = TYPE_UNGUIDED,
	ammo_scene = "res://scene/weapons/un-guided/cannon/cannon.tscn",
	min_range = 0.0,
	max_range = 40.0,
	ammo = 450,
	max_ammo = 450,
	ammo_cost = 2,
	can_fire = false
}




