extends AirPlane
class_name TacticalBomber

onready var _fuel = $Fuel
onready var _pivot = $Pivot
onready var _tag = $tag
onready var _tween = $Tween
onready var _highlight = $highlight

var delivered = false

###############################################################
# multiplayer sync
func _set_puppet_translation(_val :Vector3):
	._set_puppet_translation(_val)
	if destroyed:
		translation = _puppet_translation
		return
		
	_tween.interpolate_property(self,"translation",translation, _puppet_translation, 0.1)
	_tween.start()
	
func _set_puppet_rotation(_val:Vector3):
	._set_puppet_rotation(_val)
	if destroyed:
		rotation = _puppet_rotation
		return
	
remotesync func _take_damage(damage):
	._take_damage(damage)
	
	
remotesync func _falling():
	._falling()
	_highlight.visible = false
	_tag.visible = false
	var _down = Vector3(translation.x, 1.0, translation.y)
	look_at(_down, Vector3.UP)
	_tween.interpolate_property(_pivot, "rotation", _pivot.rotation,  Vector3(0,0,120), 10.0)
	_tween.interpolate_property(self, "translation", translation, _down, rand_range(3.0,4.0))
	_tween.start()
	
remotesync func _deliver_payload():
	var projectile = load("res://scene/weapons/un-guided/bomb/bomb.tscn").instance()
	projectile.damage = damage
	projectile.speed = speed * 2
	projectile.owner_id = owner_id
	projectile.side = side
	projectile.tag_color = tag_color
	get_parent().add_child(projectile)
	projectile.translation = translation
	projectile.lauching_at(_target.translation)
	
###############################################################



# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	_tag.modulate = tag_color
	_highlight.highlight(false)
	
	
func highlight(_show : bool):
	_highlight.highlight(_show)
	
	
func _process(delta):
	._process(delta)
		
	if get_tree().network_peer and not is_network_master():
		return
		
	master_movement(delta)
	
	
func master_movement(delta):
	if is_instance_valid(_target) and not _mission_over:
		var target_translation = _target.translation + Vector3(0, DEFAULT_ALTITUDE, 0)
		var distance_to_target = translation.distance_to(target_translation)
		if distance_to_target <= 1.0 and not delivered:
			deliver_payload()
			delivered = true
			return
			
		.transform_turning(target_translation, delta)
		move_and_slide(translation.direction_to(target_translation) * speed)
		
	if _mission_over:
		var landing_target = get_parent().translation
		.transform_turning(landing_target, delta)
		var collide = move_and_collide(translation.direction_to(landing_target) * speed * delta)
		if collide:
			.perform_landing(collide.get_collider())
			
		
	# target destroy or fuel empty
	_mission_over = not is_instance_valid(_target) or _fuel.is_stopped() or delivered
	
	
func lauching_at(to: Spatial):
	.lauching_at(to)
	_fuel.wait_time = fuel
	_tag.modulate = tag_color
	_fuel.start()
	
	
	
func _on_Tween_tween_completed(object, key):
	if not destroyed:
		return
		
	if str(key) == ":translation":
		.spawn_explosive_on_destroy()
	
	
	
func deliver_payload():
	if get_tree().network_peer:
		rpc("_deliver_payload")
		return
		
	_deliver_payload()
	




