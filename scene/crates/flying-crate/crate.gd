extends Area
class_name FlyingCrate

const CONTENT_TYPE_AMMO = "res://scene/crates/flying-crate/ammo_crate.png"
const CONTENT_TYPE_HP = "res://scene/crates/flying-crate/hp_crate.png"
const CONTENT_TYPE_CASH = "res://scene/crates/flying-crate/cash_crate.png"
const CONTENTS = [CONTENT_TYPE_AMMO, CONTENT_TYPE_HP, CONTENT_TYPE_CASH]

const MINIMAP_MARKER = "weapon"
var MINIMAP_COLOR = Color.orange

signal on_pickup(_node, _by)

onready var _tag = $tag
onready var _tween = $Tween

var tag_color = MINIMAP_COLOR
var owner_id = ""
var side = ""

var damage = 0
var speed = 0.4
var spread = 0.2
var altitude = 10.0

var content_type = CONTENT_TYPE_HP

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
	
remotesync func _despawn():
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
	_tag.texture = load(content_type)
	set_as_toplevel(true)
	
func _process(delta):
	if get_tree().network_peer and not is_network_master():
		return
		
	if translation.y < altitude:
		translation.y += 1.0 * delta
		
	translation += _velocity * speed * delta
	
func despawn():
	if get_tree().network_peer:
		rpc("_despawn")
		return
		
	_despawn()
	
func _on_Timer_timeout():
	despawn()
	
func lauching_at(to: Vector3, dis : float):
	_velocity = Vector3.ONE * rand_range(-2.0,2.0)
	_velocity.y = translation.y
	_velocity = translation.direction_to(_velocity)
	
func _on_crate_body_entered(body):
	if body.is_a_parent_of(self):
		return
		
	if not body is KinematicBody:
		return
		
	if body.owner_id == owner_id or body.side == side:
		return
		
	if not body.has_method("take_damage"):
		return
		
	if not body.has_method("restore_hp"):
		return
		
	emit_signal("on_pickup",self, body)
		
	if get_tree().network_peer and is_network_master():
		rpc("_despawn")
		return
		
	despawn()
