extends AirPlane

onready var _firing_delay = $FiringDelay
onready var _fuel = $Fuel
onready var _mg_firing = $Pivot/mg_firing
onready var _pivot = $Pivot
onready var _tag = $tag
onready var _tween = $Tween
onready var _highlight = $highlight

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
	_mg_firing.visible = false
	_tag.visible = false
	var _down = Vector3(translation.x, 1.0, translation.y)
	look_at(_down, Vector3.UP)
	_tween.interpolate_property(_pivot, "rotation", _pivot.rotation,  Vector3(0,0,120), 10.0)
	_tween.interpolate_property(self, "translation", translation, _down, rand_range(4.0,6.0))
	_tween.start()
	
###############################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	_highlight.highlight(false)
	_tag.modulate = tag_color
	
func highlight(_show : bool):
	if destroyed:
		return
		
	_highlight.highlight(_show)
	
	
func _process(delta):
	._process(delta)
	
	if get_tree().network_peer and not is_network_master():
		return
		
	if is_instance_valid(_target) and not _mission_over:
		var distance_to_target = translation.distance_to(_target.translation)
		var distance_to_waypoint = translation.distance_to(_waypoint)
		
		_mg_firing.visible = (ranges >= distance_to_target) and not _mission_over
			
		if distance_to_waypoint <= 5.0:
			.update_course()
			
		if  _firing_delay.is_stopped() and _mg_firing.visible:
			shot_bullet()
			_firing_delay.start()
		
		.transform_turning(_waypoint, delta)
		move_and_slide(translation.direction_to(_waypoint) * speed)
		
	if _mission_over:
		var landing_target = get_parent().translation
		.transform_turning(landing_target, delta)
		var collide = move_and_collide(translation.direction_to(landing_target) * speed * delta)
		if collide:
			.perform_landing(collide.get_collider())
			
		
	# target destroy or fuel empty
	_mission_over = not is_instance_valid(_target) or _fuel.is_stopped()
	
	
func shot_bullet():
	if _target.has_method("take_damage") and randf() < accuracy:
		_target.take_damage(damage)
		
	var projectile = load("res://scene/weapons/un-guided/bullet/bullet.tscn").instance()
	add_child(projectile)
	projectile.lauching_at(_target.translation)
	
	
func lauching_at(to: Spatial):
	.lauching_at(to)
	_fuel.wait_time = fuel
	_tag.modulate = tag_color
	_fuel.start()
	
	
	
func _on_UpdateCourse_timeout():
	.update_course()
	

	
func _on_Tween_tween_completed(object, key):
	if not destroyed:
		return
		
	if str(key) == ":translation":
		.spawn_explosive_on_destroy()
	




