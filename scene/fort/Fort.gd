extends KinematicBody
class_name Fort

const DEFAULT_ALTITUDE = 0.0
const MINIMAP_MARKER = "troop"
var MINIMAP_COLOR = Color.white

signal on_click(_node)
signal on_ready(_node)
signal on_take_damage(_node, damage, hp)
signal on_weapon_update(_node, _weapon_index, _weapon)
signal on_spawning_weapon(_node)
signal on_destroyed(_node)

# targeting
var _shot_delay_timer : Timer = null
var _switch_target_timer : Timer = null
var firing_delay = 0.1
var targets = []
var _target = null

var aim_point : Vector3
var guided_point : Spatial
var lock_on_point : Spatial

# weapon system slots
var weapons = []

# vitality
var destroyed = false
var hp = 100.0
var max_hp = 100.0

var tag_color = Color.white
var owner_id = ""
var side = ""

###############################################################
# multiplayer sync
remotesync func _take_damage(damage):
	if destroyed:
		return
		
	hp = round(hp - damage)
	
	if hp < 0.0:
		destroy()
		
	emit_signal("on_take_damage", self, damage , hp)
	
remotesync func _shot(weapon_index : int, name : String, _aim_point : Vector3, _guided_point : NodePath, _lock_on_point : NodePath):
	_launch(weapon_index, name, _aim_point, _guided_point, _lock_on_point)
	
remotesync func _restock_ammo(weapon_slot, ammo_restock):
	if weapons[weapon_slot].ammo >= weapons[weapon_slot].max_ammo:
		return
		
	if (weapons[weapon_slot].ammo + ammo_restock) >  weapons[weapon_slot].max_ammo:
		weapons[weapon_slot].ammo = weapons[weapon_slot].max_ammo
		return
		
	weapons[weapon_slot].ammo += ammo_restock
	
remotesync func _restock_hp(_hp):
	if hp >= max_hp:
		return
		
	if (hp + _hp) > hp:
		hp = max_hp
		return
		
	hp += _hp
	
###############################################################

func make_ready():
	_ready()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if not _shot_delay_timer:
		_shot_delay_timer = Timer.new()
		_shot_delay_timer.wait_time = firing_delay
		_shot_delay_timer.connect("timeout", self , "_on_shot_delay_timer_timeout")
		_shot_delay_timer.autostart = true
		add_child(_shot_delay_timer)
		
	if not _switch_target_timer:
		_switch_target_timer = Timer.new()
		_switch_target_timer.wait_time = 5.0
		_switch_target_timer.connect("timeout", self , "_on_switch_target_timer_timeout")
		_switch_target_timer.autostart = true
		add_child(_switch_target_timer)
		
	destroyed = false
	visible = true
	set_process(false)
	
	emit_signal("on_ready", self)
	
func set_data(_fort_data):
	max_hp = _fort_data.max_hp
	hp = _fort_data.hp
	firing_delay = _fort_data.firing_delay
	
	weapons.clear()
	for i in _fort_data.weapons:
		weapons.append(i.duplicate())
		
	set_skin(_fort_data.skin)
	
func set_hp_bar_color(_color : Color):
	tag_color = _color
	
func show_hp_bar(_show : bool):
	pass
	
func update_hp_bar():
	pass
	
func set_hp_bar_name(_name):
	pass
	
func set_skin(_camo : String = ""):
	pass
	
func take_damage(damage):
	if get_tree().network_peer:
		rpc("_take_damage",damage)
		return
		
	_take_damage(damage)
	
func destroy():
	destroyed = true
	spawn_explosive_on_destroy()
	
	
func shot(weapon_index : int, _aim_point : Vector3 = Vector3.ZERO, _guided_point : NodePath = NodePath(""), _lock_on_point : NodePath = NodePath("")):
	var _weapon_name = "weapon-" + str(GDUUID.v4())
	
	if get_tree().network_peer:
		rpc("_shot", weapon_index, _weapon_name,  _aim_point, _guided_point, _lock_on_point)
		return
		
	_shot(weapon_index, _weapon_name, _aim_point, _guided_point, _lock_on_point)
	
func _launch(weapon_index : int, name : String, _aim_point : Vector3, _guided_point : NodePath, _lock_on_point : NodePath):
	if destroyed:
		return
		
	if weapons.empty():
		return
		
	var weapon = weapons[weapon_index]
		
	if weapons[weapon_index].ammo <= 0:
		return
		
	if not _aim_point == Vector3.ZERO:
		aim_point = _aim_point
		
	if not _guided_point.is_empty():
		guided_point = get_node(_guided_point)
		
	if not _lock_on_point.is_empty():
		lock_on_point = get_node(_lock_on_point)
		
		
	var projectile = load(weapon.ammo_scene).instance()
	projectile.set_network_master(get_network_master())
	projectile.name = name
	projectile.damage = weapon.damage
	projectile.speed = weapon.speed
	projectile.owner_id = owner_id
	projectile.side = side
	projectile.tag_color = tag_color
	
	if weapon.type == Weapons.TYPE_UNGUIDED and aim_point:
		var _aim_at = aim_point
		if is_instance_valid(lock_on_point):
			_aim_at = lock_on_point.translation
			
		var distance_to_target = translation.distance_to(_aim_at)
		if distance_to_target > weapon.max_range or distance_to_target < weapon.min_range:
			return
			
		weapons[weapon_index].ammo -= 1
			
		add_child(projectile)
		projectile.translation = translation
		projectile.lauching_at(_aim_at, distance_to_target)
		
		play_sound("res://assets/sounds/cannon.wav")
		
	if weapon.type == Weapons.TYPE_GUIDED and is_instance_valid(guided_point):
		var distance_to_target = translation.distance_to(guided_point.translation)
		if distance_to_target > weapon.max_range or distance_to_target < weapon.min_range:
			return
			
		weapons[weapon_index].ammo -= 1
			
		add_child(projectile)
		projectile.translation = translation
		projectile.lauching_at(guided_point)
		play_sound("res://assets/sounds/cant_click.wav")
		
		emit_signal("on_spawning_weapon", projectile)
		
	if weapon.type == Weapons.TYPE_LOCK_ON and is_instance_valid(lock_on_point):
		var distance_to_target = translation.distance_to(lock_on_point.translation)
		if distance_to_target > weapon.max_range or distance_to_target < weapon.min_range:
			return
			
		weapons[weapon_index].ammo -= 1
			
		add_child(projectile)
		projectile.translation = translation
		projectile.lauching_at(lock_on_point)
		play_sound("res://assets/sounds/cant_click.wav")
		
		emit_signal("on_spawning_weapon", projectile)
		
	if weapon.type == Weapons.TYPE_CONTROLLED and is_instance_valid(lock_on_point):
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
	
func restock_ammo(weapon_slot : int, ammo_restock : float):
	if get_tree().network_peer:
		rpc("_restock_ammo",weapon_slot, ammo_restock)
		return
		
	_restock_ammo(weapon_slot, ammo_restock)
	
	
func play_sound(path : String):
	pass
	
	
func spawn_explosive_on_destroy():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	explosive.connect("on_finish_explode", self , "_on_finish_explode")
	add_child(explosive)
	explosive.translation = translation
	explosive.scale = Vector3.ONE * 10
	
func _on_finish_explode():
	emit_signal("on_destroyed", self)
	
func _on_switch_target_timer_timeout():
	if get_tree().network_peer and not is_network_master():
		return
		
	if targets.empty():
		return
		
	erase_empty(targets)
		
	if targets.empty():
		return
		
	_target = targets[randi() % targets.size()]
		
		
func _on_shot_delay_timer_timeout():
	if get_tree().network_peer and not is_network_master():
		return
		
	if not is_instance_valid(_target):
		return
		
	var slot = rand_range(0, weapons.size())
	
	shot(slot,_target.translation,_target.get_path(),_target.get_path())
	
	
func erase_empty(arr):
	var erase_target = []
	for i in arr:
		if not is_instance_valid(i):
			erase_target.append(i)
		
	for i in erase_target:
		arr.erase(i)
	










