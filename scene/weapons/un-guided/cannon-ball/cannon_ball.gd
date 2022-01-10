extends Spatial

var tag_color = Color.white
var owner_id = ""
var side = ""

var damage = 15.0
var speed = 10.0
var spread = 0.2

var _velocity : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)

func _process(delta):
	translation += _velocity * speed * delta
	
func lauching_at(to: Vector3):
	_velocity = translation.direction_to(to)
	_velocity.z += rand_range(-spread, spread)
	_velocity.x += rand_range(-spread, spread)
	
	
func _on_cannonBall_body_entered(body):
	if body.is_a_parent_of(self):
		return
		
	if not body is KinematicBody:
		return
		
	if body.has_method("take_damage"):
		body.take_damage(Weapon.get_damage_mult(damage))
		
	spawn_explosive()
	
func _on_Timer_timeout():
	spawn_explosive()
	
	
func spawn_explosive():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	get_parent().add_child(explosive)
	explosive.translation = translation
	explosive.scale = Vector3.ONE * 3
	queue_free()
	
	
	
