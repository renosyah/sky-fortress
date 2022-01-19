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

###############################################################
# multiplayer sync
var _network_timmer : Timer = null
func _network_timmer_timeout():
	if destroyed:
		return
		
	if get_tree().network_peer and is_network_master():
		rset_unreliable("_puppet_translation", translation)
		rset_unreliable("_puppet_rotation", rotation)
		
	
puppet var _puppet_translation :Vector3 setget _set_puppet_translation
func _set_puppet_translation(_val :Vector3):
	_puppet_translation = _val
	
puppet var _puppet_rotation: Vector3 setget _set_puppet_rotation
func _set_puppet_rotation(_val:Vector3):
	_puppet_rotation = _val
	
remotesync func _take_damage(damage):
	if destroyed:
		return
		
	spawn_small_explosive_on_damage()
	hp -= damage
	if hp > 0:
		return
		
	destroyed = true
	set_process(false)
	falling()
	
remotesync func _falling():
	pass
	
remotesync func clean_it():
	queue_free()
	
###############################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	if not _network_timmer:
		_network_timmer = Timer.new()
		_network_timmer.wait_time = 0.08
		_network_timmer.connect("timeout", self , "_network_timmer_timeout")
		_network_timmer.autostart = true
		add_child(_network_timmer)
		
	MINIMAP_COLOR = tag_color
	set_as_toplevel(true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if destroyed:
		return
		
	# is a puppet
	if get_tree().network_peer and not is_network_master():
		rotation.x = lerp_angle(rotation.x, _puppet_rotation.x, delta * 5)
		rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, delta * 5)
		rotation.z = lerp_angle(rotation.z, _puppet_rotation.z, delta * 5)
		return
	
func lauching_at(to: Spatial):
	_target = to
	_waypoint = _target.translation
	
	
	
func take_damage(damage):
	if get_tree().network_peer:
		rpc("_take_damage", damage)
		return
		
	_take_damage(damage)
	
func falling():
	if get_tree().network_peer:
		rpc("_falling")
		return
	
	_falling()
	
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
	
	if get_tree().network_peer:
		rpc("clean_it")
		return
		
	clean_it()
	
func spawn_small_explosive_on_damage():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	get_parent().add_child(explosive)
	explosive.translation = translation
	explosive.scale = Vector3.ONE * 3
	
func spawn_small_explosive_on_hit_enemy(_translation):
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	get_parent().add_child(explosive)
	explosive.translation = _translation
	
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
		
	if get_tree().network_peer:
		rpc("clean_it")
		return
		
	clean_it()







