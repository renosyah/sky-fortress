extends AirPlane

onready var _fuel = $Fuel
onready var _pivot = $Pivot
onready var _tag = $tag
onready var _tween = $Tween
onready var _highlight = $highlight

var delivered = false

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	_tag.modulate = tag_color
	_highlight.highlight(false)
	
func highlight(_show : bool):
	_highlight.highlight(_show)
	
func _process(delta):
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
		move_and_slide(translation.direction_to(landing_target) * speed)
		
	# target destroy or fuel empty
	_mission_over = not is_instance_valid(_target) or _fuel.is_stopped() or delivered
	
	
	
	
func lauching_at(to: Spatial):
	.lauching_at(to)
	_fuel.wait_time = fuel
	_tag.modulate = tag_color
	_fuel.start()
	
	
	
	
func _on_Area_body_entered(body):
	.perform_landing(body)
	
	
	
func take_damage(damage):
	.take_damage(damage)
	
	
	
func falling():
	.falling()
	_highlight.visible = false
	_tag.visible = false
	var _down = Vector3(translation.x, 1.0, translation.y)
	look_at(_down, Vector3.UP)
	_tween.interpolate_property(_pivot, "rotation", _pivot.rotation,  Vector3(0,0,120), rand_range(4.0,6.0))
	_tween.interpolate_property(self, "translation", translation, _down, rand_range(2.0,4.0))
	_tween.start()
	
	
	
func _on_Tween_tween_completed(object, key):
	if str(key) == ":translation":
		.spawn_explosive_on_destroy()
	
	
	
func deliver_payload():
	var projectile = load("res://scene/weapons/un-guided/bomb/bomb.tscn").instance()
	projectile.damage = damage
	projectile.speed = speed * 2
	projectile.owner_id = owner_id
	projectile.side = side
	projectile.tag_color = tag_color
	get_parent().add_child(projectile)
	projectile.translation = translation
	projectile.lauching_at(_target.translation)




