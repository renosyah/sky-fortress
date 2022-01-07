extends KinematicBody
class_name Ship

const DEFAULT_ALTITUDE = 10.0
const MINIMAP_MARKER = "troop"
const MINIMAP_COLOR = Color.white

signal on_move(_node, _translation)
signal on_ready(_node)
signal on_take_damage(_node, damage, hp)
signal on_falling(_node)
signal on_destroyed(_node)

# targeting
var aim_point : Vector3
var guided_point : Spatial
var lock_on_point : Spatial

# weapon system slots
var weapons = Weapon.TEMPLATES

# mobility
var waypoint = null #vector3
var cruise_speed = 4.0
var turn_speed = 1.5
var altitude = DEFAULT_ALTITUDE

# vitality
var destroyed = false
var hp = 100.0
var max_hp = 100.0

func set_hp_bar_color(_color : Color):
	pass
	
func show_hp_bar(_show : bool):
	pass
	
func take_damage(damage):
	pass
	
func destroy():
	pass
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func make_ready():
	pass
	
func shot(weapon_index : int):
	if destroyed:
		return
	if weapons.empty():
		return
		
	var weapon = weapons[weapon_index]
	var projectile = load(weapon.ammo_scene).instance()
	projectile.damage = weapon.damage
	projectile.speed = weapon.speed
	
	if weapon.type == Weapon.TYPE_UNGUIDED and aim_point:
		var distance_to_target = translation.distance_to(aim_point)
		if distance_to_target > weapon.max_range or distance_to_target < weapon.min_range:
			return
			
		add_child(projectile)
		projectile.translation = translation
		projectile.lauching_at(aim_point)
		
	if weapon.type == Weapon.TYPE_GUIDED and is_instance_valid(guided_point):
		var distance_to_target = translation.distance_to(guided_point.translation)
		if distance_to_target > weapon.max_range or distance_to_target < weapon.min_range:
			return
			
		add_child(projectile)
		projectile.translation = translation
		projectile.lauching_at(guided_point)
		
	if weapon.type == Weapon.TYPE_LOCK_ON and is_instance_valid(lock_on_point):
		var distance_to_target = translation.distance_to(lock_on_point.translation)
		if distance_to_target > weapon.max_range or distance_to_target < weapon.min_range:
			return
			
		add_child(projectile)
		projectile.translation = translation
		projectile.lauching_at(lock_on_point)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector3.ZERO
	var direction = Vector3.ZERO
	var distance_to_target = 0.0
	
	if destroyed:
		return
		
	if waypoint:
		direction = translation.direction_to(waypoint)
		distance_to_target = translation.distance_to(waypoint)
		
		if distance_to_target > 1.0:
			velocity = Vector3(direction.x, 0.0, direction.z) * cruise_speed
			var new_transform = transform.looking_at((Vector3(waypoint.x , translation.y, waypoint.z)), Vector3.UP)
			transform = transform.interpolate_with(new_transform, turn_speed * delta)
			emit_signal("on_move",self, translation)
			
		else:
			waypoint = null
		
		move_and_slide(velocity)














