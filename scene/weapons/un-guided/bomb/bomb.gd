extends Area

onready var _tag = $tag
onready var _pivot = $Pivot

var tag_color = Color.white
var owner_id = ""
var side = ""

var damage = 35.0
var speed = 3.0
var spread = 0.2

var _velocity : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	_tag.modulate = tag_color
	set_as_toplevel(true)
	
func _process(delta):
	var _target = Vector3(translation.x, 0.0, translation.z).normalized()
	translation += _velocity * speed * delta
	
func _on_Timer_timeout():
	spawn_explosive()
	
func lauching_at(_to: Vector3):
	_velocity = translation.direction_to(Vector3(translation.x, 0.0, translation.z))
	_velocity.x += rand_range(-spread, spread)
	_velocity.z += rand_range(-spread, spread)
	
func _on_bomb_body_entered(body):
	if body.is_a_parent_of(self):
		return
		
	if body is StaticBody:
		spawn_explosive()
		return
		
	if not body is KinematicBody:
		return
		
	if body.owner_id == owner_id or body.side == side:
		return
		
	if get_tree().network_peer and not is_network_master():
		spawn_explosive()
		return
		
	if body.has_method("take_damage"):
		body.take_damage(Weapon.get_damage_mult(damage))
		
	spawn_explosive()
	
	
func spawn_explosive():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	get_parent().add_child(explosive)
	explosive.translation = translation
	explosive.scale = Vector3.ONE * 10
	queue_free()
	
	

