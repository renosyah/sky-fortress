extends KinematicBody

const MINIMAP_MARKER = "weapon"
var MINIMAP_COLOR = Color.white

onready var _firing_delay = $FiringDelay
onready var _fuel = $Fuel
onready var _mg_firing = $Pivot/mg_firing
onready var _pivot = $Pivot
onready var _tag = $tag
onready var _tween = $Tween

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

var hp = 1.0
var max_hp = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	_tag.modulate = tag_color
	MINIMAP_COLOR = tag_color
	set_as_toplevel(true)

func _process(delta):
	if is_instance_valid(_target) and not _mission_over:
		var distance_to_target = translation.distance_to(_target.translation)
		var distance_to_waypoint = translation.distance_to(_waypoint)
		var direction = translation.direction_to(_waypoint)
		_mg_firing.visible = (ranges >= distance_to_target)
			
		if distance_to_waypoint <= 5.0:
			_update_course()
			
		if  _firing_delay.is_stopped() and _mg_firing.visible:
			if _target.has_method("take_damage") and randf() < accuracy:
				_target.take_damage(damage)
			_shot_bullet()
			_firing_delay.start()
			
		var new_transform = transform.looking_at(_waypoint, Vector3.UP)
		transform = transform.interpolate_with(new_transform, speed * delta)
		
		move_and_slide(direction * speed)
		
	if _mission_over:
		_mg_firing.visible = false
		var landing_target = get_parent().translation
		var direction = translation.direction_to(landing_target)
		var new_transform = transform.looking_at(landing_target, Vector3.UP)
		transform = transform.interpolate_with(new_transform, speed * delta)
		
		move_and_slide(direction * speed)
		
	# target destroy or fuel empty
	_mission_over = not is_instance_valid(_target) or _fuel.is_stopped()
		
func lauching_at(to: Spatial):
	_target = to
	_waypoint = _target.translation
	_fuel.wait_time = fuel
	_tag.modulate = tag_color
	_fuel.start()
	
func _shot_bullet():
	var projectile = load("res://scene/weapons/un-guided/bullet/bullet.tscn").instance()
	add_child(projectile)
	projectile.lauching_at(_target.translation)
	
	
func _update_course():
	if is_instance_valid(_target):
		while translation.distance_to(_waypoint) < 5.0:
			_waypoint = Vector3.ONE * rand_range(-12.0, 12.0) + _target.translation
		
	_waypoint.y = rand_range(8.0,20.0)

func _on_UpdateCourse_timeout():
	_update_course()
	
func _on_Area_body_entered(body):
	if not _mission_over:
		return
		
	if not body is KinematicBody:
		return
		
	if not body.is_a_parent_of(self):
		return
		
	if body.has_method("restock_ammo"):
		body.restock_ammo(weapon_slot, ammo_restock)
		
	queue_free()
	
func take_damage(damage):
	hp -= damage
	if hp > 0:
		return
		
	set_process(false)
	_mg_firing.visible = false
	_tag.visible = false
	var _down = Vector3(translation.x, 1.0, translation.y)
	look_at(_down, Vector3.UP)
	_tween.interpolate_property(_pivot, "rotation", _pivot.rotation,  Vector3(0,0,120), rand_range(4.0,6.0))
	_tween.interpolate_property(self, "translation", translation, _down, rand_range(2.0,4.0))
	_tween.start()
	
func _on_Tween_tween_completed(object, key):
	if str(key) == ":translation":
		spawn_explosive_on_destroy()
	
func spawn_explosive_on_destroy():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	get_parent().add_child(explosive)
	explosive.translation = translation
	explosive.scale = Vector3.ONE * 10
	queue_free()



