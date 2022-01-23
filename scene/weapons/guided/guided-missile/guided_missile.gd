extends KinematicBody

const MINIMAP_MARKER = "weapon"
var MINIMAP_COLOR = Color.white

var tag_color = Color.white
var owner_id = ""
var side = ""

var damage = 20.0
var speed = 5.0

var _stay_on = true
var _target : Spatial
var _direction = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)

func _process(delta):
	if is_instance_valid(_target):
		if _stay_on:
			var new_transform = transform.looking_at(_target.translation, Vector3.UP)
			transform = transform.interpolate_with(new_transform, speed * delta)
			move_and_collide(_direction * speed * delta)
		else:
			translation += _direction * speed * delta
			
		var distance_to_target = translation.distance_to(_target.translation)
		if _stay_on:
			_direction = translation.direction_to(_target.translation)
			_stay_on = distance_to_target > 1.0
	else:
		set_process(false)
		spawn_explosive()
		
func lauching_at(to: Spatial):
	_target = to
	_direction = translation.direction_to(_target.translation)
	
	
func _on_Timer_timeout():
	spawn_explosive()
	
func _on_Area_body_entered(body):
	if body.is_a_parent_of(self):
		return
		
	if not body is KinematicBody:
		return
		
	if body.owner_id == owner_id or body.side == side:
		return
		
	if get_tree().network_peer and not is_network_master():
		spawn_explosive()
		return
		
	if body.has_method("take_damage"):
		body.take_damage(Weapons.get_damage_mult(damage))
		
	spawn_explosive()
	
	
func spawn_explosive():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	get_parent().add_child(explosive)
	explosive.translation = translation
	explosive.scale = Vector3.ONE * 6
	queue_free()
	
	
	
	
