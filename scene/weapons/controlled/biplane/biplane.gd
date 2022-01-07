extends KinematicBody

onready var _firing_delay = $FiringDelay
onready var _mission_time = $MissionTime
onready var _mg_firing = $mg_firing


var firing_range = 15.0
var damage = 5.0
var speed = 5.0
var mission_time = 35.0
var accuracy = 0.4

var mission_over = false
var _waypoint : Vector3
var _target : Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)

func _process(delta):
	if is_instance_valid(_target) and not mission_over:
		var distance_to_target = translation.distance_to(_waypoint)
		var direction = translation.direction_to(_waypoint)
		_mg_firing.visible = (firing_range >= distance_to_target)
		
		if  _firing_delay.is_stopped() and _mg_firing.visible:
			if _target.has_method("take_damage") and randf() < accuracy:
				_target.take_damage(damage)
			_firing_delay.start()
			
		var new_transform = transform.looking_at(_waypoint, Vector3.UP)
		transform = transform.interpolate_with(new_transform, speed * delta)
		move_and_slide(direction * speed)
		
	if mission_over:
		_mg_firing.visible = false
		var landing_target = get_parent().translation
		var direction = translation.direction_to(landing_target)
		var new_transform = transform.looking_at(landing_target, Vector3.UP)
		transform = transform.interpolate_with(new_transform, speed * delta)
		move_and_slide(direction * speed)
		
	mission_over = not is_instance_valid(_target)
		
func lauching_at(to: Spatial):
	_target = to
	_mission_time.wait_time = mission_time
	_mission_time.start()
	
func _on_UpdateCourse_timeout():
	if is_instance_valid(_target):
		_waypoint = Vector3.ONE * rand_range(-25.0, 25.0) + _target.translation
		_waypoint.y = rand_range(10,25)
	
func _on_MissionTime_timeout():
	mission_over = true
	
func _on_Area_body_entered(body):
	if not mission_over:
		return
		
	if not body is KinematicBody:
		return
		
	if not body.is_a_parent_of(self):
		return
		
	queue_free()
	
func take_damage(damage):
	queue_free()
	
	

