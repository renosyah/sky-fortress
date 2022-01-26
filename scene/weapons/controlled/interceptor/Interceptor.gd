extends AirPlane
class_name Interceptor

onready var _fuel = $Fuel
onready var _pivot = $Pivot
onready var _tag = $tag
onready var _tween = $Tween
onready var _tween2 = $Tween2
onready var _highlight = $highlight
onready var _input_detection = $inputDetection

var delivered = false
var ready_attack = false

###############################################################
# multiplayer sync
func _set_puppet_translation(_val :Vector3):
	._set_puppet_translation(_val)
	if destroyed:
		translation = _puppet_translation
		return
		
	_tween2.interpolate_property(self,"translation",translation, _puppet_translation, 0.1)
	_tween2.start()
	
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
	var projectile = load("res://scene/weapons/lock-on/lock-on-missile/lock_on_missile.tscn").instance()
	projectile.damage = damage
	projectile.speed = speed 
	projectile.owner_id = owner_id
	projectile.side = side
	projectile.tag_color = tag_color
	projectile.set_network_master(get_network_master())
	get_parent().add_child(projectile)
	projectile.translation = translation
	projectile.lauching_at(_target)
	
###############################################################
	
# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	_highlight.highlight(false)
	
	if not is_connected("input_event", self , "_on_input_event"):
		connect("input_event", self , "_on_input_event")
		
	if not _input_detection.is_connected("any_gesture", self, "_on_inputDetection_any_gesture"):
		_input_detection.connect("any_gesture", self, "_on_inputDetection_any_gesture")
		
	_tag.modulate = tag_color
	
func highlight(_show : bool):
	_highlight.highlight(_show)
	
	
func _process(delta):
	._process(delta)
		
	if get_tree().network_peer and not is_network_master():
		return
		
	master_movement(delta)
	
	
func master_movement(delta):
	if is_instance_valid(_target) and not _mission_over:
		var distance_to_target = translation.distance_to(_target.translation)
		var distance_to_waypoint = translation.distance_to(_waypoint)
		
		if distance_to_waypoint <= 5.0:
			.update_course()
			ready_attack = randf() < accuracy
			
		if distance_to_target <= 15.0 and not delivered and ready_attack:
			deliver_payload()
			delivered = true
			return
		
		.transform_turning(_waypoint, delta)
		move_and_slide(translation.direction_to(_waypoint) * speed)
		
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
	
func _on_UpdateCourse_timeout():
	.update_course()
	
func deliver_payload():
	if get_tree().network_peer:
		rpc("_deliver_payload")
		return
		
	_deliver_payload()
	
func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.is_action_pressed("left_click"):
		emit_signal("on_click", self)
		
	_input_detection.check_input(event)
	
	
func _on_inputDetection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_click", self)
	



