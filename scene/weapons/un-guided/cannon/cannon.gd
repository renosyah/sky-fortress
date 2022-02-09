extends Spatial

const MAX_DISTANCE = 45.0

var tag_color = Color.white
var owner_id = ""
var side = ""

var damage = 15.0
var speed = 10.0
var spread = 0.2

var _velocity : Vector3
var _travel_distance : float = 0.0
var _max_distance : float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)

func _process(delta):
	var _distance = speed * delta
	translation += _velocity * _distance
	_travel_distance += _distance
	
	if _travel_distance > _max_distance:
		set_process(false)
		spawn_explosive()
	
func lauching_at(to: Vector3, dis : float = MAX_DISTANCE):
	_velocity = translation.direction_to(to)
	_velocity.z += rand_range(-spread, spread)
	_velocity.x += rand_range(-spread, spread)
	_max_distance = rand_range(dis - 1.0, dis + 1.0)
	look_at(to,Vector3.UP)
	
	
func _on_cannonBall_body_entered(body):
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
		body.take_damage(Weapons.get_damage_mult(damage), owner_id)
		
	spawn_explosive()
	
func _on_Timer_timeout():
	spawn_explosive()
	
	
func spawn_explosive():
	var explosive = preload("res://assets/explosive_flak/explosive_flak.tscn").instance()
	get_parent().add_child(explosive)
	explosive.translation = translation
	explosive.scale = Vector3.ONE * 3
	queue_free()
	
	
	
