extends Area

onready var _tag = $tag

var tag_color = Color.white
var owner_id = ""
var side = ""

var damage = 35.0
var speed = 10.0
var spread = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	_tag.modulate = tag_color
	set_as_toplevel(true)
	
	
func _on_Timer_timeout():
	spawn_explosive()
	
func lauching_at(_to: Vector3):
	pass
	
func _on_air_mine_body_entered(body):
	if body.is_a_parent_of(self):
		return
		
	if not body is KinematicBody:
		return
		
	if body.owner_id == owner_id or body.side == side:
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
	
	
	
