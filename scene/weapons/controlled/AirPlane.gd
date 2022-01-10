extends KinematicBody
class_name AirPlane

const DEFAULT_ALTITUDE = 10.0
const MINIMAP_MARKER = "weapon"
var MINIMAP_COLOR = Color.white

var tag_color = Color.white
var owner_id = ""
var side = ""

var weapon_slot = 0
var ammo_restock = 1

var ranges = 15.0
var damage = 5.0
var speed = 5.0
var fuel = 35.0
var accuracy = 0.4

var _mission_over = false
var _waypoint : Vector3
var _target : Spatial

var destroyed = false
var hp = 1.0
var max_hp = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	MINIMAP_COLOR = tag_color
	set_as_toplevel(true)
	
	
func lauching_at(to: Spatial):
	_target = to
	_waypoint = _target.translation
	
	
	
func shot_bullet():
	if _target.has_method("take_damage") and randf() < accuracy:
		_target.take_damage(damage)
		
	var projectile = load("res://scene/weapons/un-guided/bullet/bullet.tscn").instance()
	add_child(projectile)
	projectile.lauching_at(_target.translation)
	
	
	
func take_damage(damage):
	if destroyed:
		return
		
	spawn_small_explosive_on_damage()
	hp -= damage
	if hp > 0:
		return
		
	destroyed = true
	set_process(false)
	falling()
	
func falling():
	pass
	
func update_course():
	if is_instance_valid(_target):
		while translation.distance_to(_waypoint) < 5.0:
			_waypoint = Vector3.ONE * rand_range(-12.0, 12.0) + _target.translation
		
	_waypoint.y = rand_range(5.0,20.0)
	
	
func spawn_explosive_on_destroy():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	get_parent().add_child(explosive)
	explosive.translation = translation
	explosive.scale = Vector3.ONE * 10
	queue_free()
	
func spawn_small_explosive_on_damage():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	get_parent().add_child(explosive)
	explosive.translation = translation
	explosive.scale = Vector3.ONE * 6
	
func transform_turning(direction, delta):
	var new_transform = transform.looking_at(direction, Vector3.UP)
	transform = transform.interpolate_with(new_transform, speed * delta)

func perform_landing(body):
	if not _mission_over:
		return
		
	if not body is KinematicBody:
		return
		
	if not body.is_a_parent_of(self):
		return
		
	if body.has_method("restock_ammo"):
		body.restock_ammo(weapon_slot, ammo_restock)
		
	queue_free()










