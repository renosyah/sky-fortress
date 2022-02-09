extends Area

onready var _tag = $tag
onready var _tween = $Tween

var tag_color = Color.white
var owner_id = ""
var side = ""

var damage = 35.0
var speed = 0.4
var spread = 0.2

var _velocity : Vector3

###############################################################
# multiplayer sync
var _network_timmer : Timer = null
func _network_timmer_timeout():
		
	if get_tree().network_peer and is_network_master():
		rset_unreliable("_puppet_translation", translation)
		
	
puppet var _puppet_translation :Vector3 setget _set_puppet_translation
func _set_puppet_translation(_val :Vector3):
	_puppet_translation = _val
	
	_tween.interpolate_property(self,"translation",translation, _puppet_translation, 0.1)
	_tween.start()
	
remotesync func spawn_explosive():
	var explosive = preload("res://assets/explosive/explosive.tscn").instance()
	get_parent().add_child(explosive)
	explosive.translation = translation
	explosive.scale = Vector3.ONE * 10
	
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
		
	_tag.modulate = tag_color
	set_as_toplevel(true)
	
func _process(delta):
	if get_tree().network_peer and not is_network_master():
		return
		
	translation += _velocity * speed * delta
	
func _on_Timer_timeout():
	if get_tree().network_peer:
		rpc("spawn_explosive")
		return
		
	spawn_explosive()
	
func lauching_at(to: Vector3, dis : float):
	_velocity = Vector3.ONE * rand_range(-2.0,2.0)
	_velocity.y = translation.y
	_velocity = translation.direction_to(_velocity)
	
func _on_air_mine_body_entered(body):
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
		
	if get_tree().network_peer and is_network_master():
		rpc("spawn_explosive")
		return
		
	spawn_explosive()
	
	
	
	
	
