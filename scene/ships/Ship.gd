extends KinematicBody
class_name Ship

const SHIP_LIST = [
	{
		id = "",
		name = "Carrier",
		icon = "res://scene/ships/carrier/icon.png",
		scene = "res://scene/ships/carrier/carrier.tscn", 
		owner_id = "",
		side = "",
		max_hp = 150,
		hp = 150,
		cruise_speed = 2.0,
		turn_speed = 0.5,
		weapons = Weapon.CARRIER_TEMPLATES
	},
	{
		id = "",
		name = "Bomber",
		icon = "res://scene/ships/bomber/icon.png",
		scene = "res://scene/ships/bomber/bomber.tscn", 
		owner_id = "",
		side = "",
		max_hp = 250,
		hp = 250,
		cruise_speed = 3.0,
		turn_speed = 1.0,
		weapons = Weapon.BOMBER_TEMPLATES
	},
	{
		id = "",
		name = "Cruiser",
		icon = "res://scene/ships/cruiser/icon.png",
		scene = "res://scene/ships/cruiser/cruiser.tscn", 
		owner_id = "",
		side = "",
		max_hp = 100,
		hp = 100,
		cruise_speed = 4.0,
		turn_speed = 1.5,
		weapons = Weapon.CRUISER_TEMPLATES
	}
	
]

const DEFAULT_ALTITUDE = 10.0
const MINIMAP_MARKER = "troop"
var MINIMAP_COLOR = Color.white

signal on_move(_node, _translation)
signal on_ready(_node)
signal on_take_damage(_node, damage, hp)
signal on_spawning_weapon(_node)
signal on_falling(_node)
signal on_destroyed(_node)

# targeting
var aim_point : Vector3
var guided_point : Spatial
var lock_on_point : Spatial

# weapon system slots
var weapons = []

# mobility
var waypoint = null #vector3
var cruise_speed = 4.0
var turn_speed = 1.5
var altitude = DEFAULT_ALTITUDE

# vitality
var destroyed = false
var hp = 100.0
var max_hp = 100.0

var tag_color = Color.white
var owner_id = ""
var side = ""

###############################################################
# multiplayer sync
var _network_timmer : Timer = null
func _network_timmer_timeout():
	if not waypoint:
		return
		
	if is_network_master():
		rset_unreliable("_puppet_data", _get_data())
		rset_unreliable("_puppet_translation", translation)
		rset_unreliable("_puppet_rotation", rotation)
		
puppet var _puppet_data : Dictionary setget _set_puppet_data
func _set_puppet_data(_val : Dictionary):
	_puppet_data = _val
	set_data(_puppet_data)
	
puppet var _puppet_translation :Vector3 setget _set_puppet_translation
func _set_puppet_translation(_val :Vector3):
	_puppet_translation = _val
	
puppet var _puppet_rotation: Vector3 setget _set_puppet_rotation
func _set_puppet_rotation(_val:Vector3):
	_puppet_rotation = _val
	
###############################################################
	
	
func make_ready():
	_ready()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if not _network_timmer:
		_network_timmer = Timer.new()
		_network_timmer.wait_time = 0.08
		_network_timmer.connect("timeout", self , "_network_timmer_timeout")
		_network_timmer.autostart = true
		add_child(_network_timmer)
		
	destroyed = false
	visible = true
	emit_signal("on_ready", self)
	
func set_hp_bar_color(_color : Color):
	tag_color = _color
	
func set_data(_ship_data):
	max_hp = _ship_data.max_hp
	hp = _ship_data.hp
	cruise_speed = _ship_data.cruise_speed
	turn_speed = _ship_data.turn_speed
	weapons = _ship_data.weapons
	
func _get_data():
	var _ship_data = {
		max_hp = max_hp,
		hp = hp,
		cruise_speed = cruise_speed,
		turn_speed = turn_speed,
		weapons = weapons,
	}
	return _ship_data
	
func show_hp_bar(_show : bool):
	pass
	
func update_hp_bar():
	pass
	
func take_damage(damage):
	if destroyed:
		return
	
	hp = round(hp - damage)
	
	if hp < 0.0:
		destroy()
		
	emit_signal("on_take_damage", self, damage , hp)
	
func destroy():
	destroyed = true
	emit_signal("on_falling", self)
	
	
func shot(weapon_index : int):
	if destroyed:
		return
		
	if weapons.empty():
		return
	
	var weapon = weapons[weapon_index]
	
	
	if weapons[weapon_index].ammo <= 0:
		return
		
	if weapon.type == Weapon.TYPE_UTILITY:
		weapons[weapon_index].ammo -= 1
		hp += weapon.hp
		max_hp += weapon.max_hp
		cruise_speed += weapon.cruise_speed
		turn_speed += weapon.turn_speed
		update_hp_bar()
		
		emit_signal("on_ready", self)
		return
		
		
	var projectile = load(weapon.ammo_scene).instance()
	projectile.damage = weapon.damage
	projectile.speed = weapon.speed
	projectile.owner_id = owner_id
	projectile.side = side
	projectile.tag_color = tag_color
	
	if weapon.type == Weapon.TYPE_UNGUIDED and aim_point:
		var _aim_at = aim_point
		if is_instance_valid(lock_on_point):
			_aim_at = lock_on_point.translation
			
		var distance_to_target = translation.distance_to(_aim_at)
		if distance_to_target > weapon.max_range or distance_to_target < weapon.min_range:
			return
			
		weapons[weapon_index].ammo -= 1
			
		add_child(projectile)
		projectile.translation = translation
		projectile.lauching_at(_aim_at)
		
		play_sound("res://assets/sounds/cannon.wav")
		
	if weapon.type == Weapon.TYPE_GUIDED and is_instance_valid(guided_point):
		var distance_to_target = translation.distance_to(guided_point.translation)
		if distance_to_target > weapon.max_range or distance_to_target < weapon.min_range:
			return
			
		weapons[weapon_index].ammo -= 1
			
		add_child(projectile)
		projectile.translation = translation
		projectile.lauching_at(guided_point)
		play_sound("res://assets/sounds/cant_click.wav")
		
		emit_signal("on_spawning_weapon", projectile)
		
	if weapon.type == Weapon.TYPE_LOCK_ON and is_instance_valid(lock_on_point):
		var distance_to_target = translation.distance_to(lock_on_point.translation)
		if distance_to_target > weapon.max_range or distance_to_target < weapon.min_range:
			return
			
		weapons[weapon_index].ammo -= 1
			
		add_child(projectile)
		projectile.translation = translation
		projectile.lauching_at(lock_on_point)
		play_sound("res://assets/sounds/cant_click.wav")
		
		emit_signal("on_spawning_weapon", projectile)
		
	if weapon.type == Weapon.TYPE_CONTROLLED and is_instance_valid(lock_on_point):
		var distance_to_target = translation.distance_to(lock_on_point.translation)
		if distance_to_target > weapon.max_range or distance_to_target < weapon.min_range:
			return
			
		weapons[weapon_index].ammo -= 1
			
		projectile.weapon_slot = weapon_index
		projectile.ammo_restock = weapon.ammo_restock
		projectile.ranges = weapon.ranges
		projectile.fuel = weapon.fuel
		projectile.accuracy = weapon.accuracy
		projectile.tag_color = tag_color
		projectile.hp = weapon.hp
		projectile.max_hp = weapon.max_hp
		
		add_child(projectile)
		projectile.translation = translation + Vector3.ONE * rand_range(-3.0, 3.0)
		projectile.translation.y += 2.0
		projectile.lauching_at(lock_on_point)
		play_sound("res://assets/sounds/cant_click.wav")
		
		emit_signal("on_spawning_weapon", projectile)
	
func restock_ammo(weapon_slot, ammo_restock):
	if weapons[weapon_slot].ammo < weapons[weapon_slot].max_ammo:
		weapons[weapon_slot].ammo += ammo_restock
	play_sound("res://assets/sounds/click.wav")
	
	
func play_sound(path : String):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if destroyed:
		return
		
	# is a puppet
	if not is_network_master():
		rotation.x = lerp_angle(rotation.x, _puppet_rotation.x, delta * 5)
		rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, delta * 5)
		rotation.z = lerp_angle(rotation.z, _puppet_rotation.z, delta * 5)
		
		emit_signal("on_move",self, translation)
		return
		
	check_weapon_status()
	
	var velocity = Vector3.ZERO
	var direction = Vector3.ZERO
	var distance_to_target = 0.0
	
	if waypoint:
		waypoint.y = altitude
		direction = translation.direction_to(waypoint)
		distance_to_target = translation.distance_to(waypoint)
		
		if distance_to_target > 1.0:
			velocity = Vector3(direction.x, 0.0 , direction.z) * cruise_speed
			transform_turning((Vector3(waypoint.x , translation.y, waypoint.z)), delta)
			emit_signal("on_move",self, translation)
			
		else:
			waypoint = null
		
		move_and_slide(velocity)
		
func transform_turning(direction, delta):
	var new_transform = transform.looking_at(direction, Vector3.UP)
	transform = transform.interpolate_with(new_transform, turn_speed * delta)
	
func spawn_explosive_on_destroy():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	explosive.connect("on_finish_explode", self , "_on_finish_explode")
	add_child(explosive)
	explosive.translation = translation
	explosive.scale = Vector3.ONE * 10
	
func _on_finish_explode():
	visible = false
	emit_signal("on_destroyed", self)

func check_weapon_status():
	for weapon in weapons:
		weapon.can_fire = false
		
		if weapon.type == Weapon.TYPE_UNGUIDED and aim_point:
			var _aim_at = aim_point
			if is_instance_valid(lock_on_point):
				_aim_at = lock_on_point.translation
				
			var distance_to_target = translation.distance_to(_aim_at)
			weapon.can_fire = distance_to_target < weapon.max_range and distance_to_target > weapon.min_range
			
		if weapon.type == Weapon.TYPE_GUIDED and is_instance_valid(guided_point):
			var distance_to_target = translation.distance_to(guided_point.translation)
			weapon.can_fire = distance_to_target < weapon.max_range and distance_to_target > weapon.min_range
			
		if weapon.type == Weapon.TYPE_LOCK_ON and is_instance_valid(lock_on_point):
			var distance_to_target = translation.distance_to(lock_on_point.translation)
			weapon.can_fire =  distance_to_target < weapon.max_range and distance_to_target > weapon.min_range
			
		if weapon.type == Weapon.TYPE_CONTROLLED and is_instance_valid(lock_on_point):
			var distance_to_target = translation.distance_to(lock_on_point.translation)
			weapon.can_fire = distance_to_target < weapon.max_range and distance_to_target > weapon.min_range
			







