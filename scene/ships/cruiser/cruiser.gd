extends Ship
const MAX_PART_DAMAGE = 10
onready var _part = $pivot
onready var _tween = $Tween
onready var _hp_bar = $hpBar
onready var _viewport_hp_bar = $hpBar/Viewport
onready var _2d_hp_bar = $hpBar/Viewport/TextureProgress

func make_ready():
	_ready()
	emit_signal("on_ready", self)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in _part.get_children():
		i.visible = true
		
	_2d_hp_bar.max_value = max_hp
	_2d_hp_bar.value = hp
	_hp_bar.texture = _viewport_hp_bar.get_texture()
	
func set_hp_bar_color(_color : Color):
	_2d_hp_bar.tint_progress = _color
	
func show_hp_bar(_show : bool):
	_hp_bar.visible = _show
	
func take_damage(damage):
	if destroyed:
		return
		
	hp -= damage
	if hp < 0.0:
		destroy()
		
	_2d_hp_bar.max_value = max_hp
	_2d_hp_bar.value = hp
	_damage_random_part()
	
	emit_signal("on_take_damage", self, damage , hp)
	
func destroy():
	_hp_bar.visible = false
	destroyed = true
	emit_signal("on_falling", self)
	_tween.interpolate_property(self, "translation", translation, Vector3(translation.x, 1.0, translation.y), rand_range(4.0,8.0))
	_tween.start()
	
func _on_Tween_tween_completed(object, key):
	if str(key) == ":translation":
		emit_signal("on_destroyed", self)
	
	
func _damage_random_part():
	var damage_part = 0
	var parts = _part.get_children()
	for i in parts:
		if i.visible == false:
			damage_part += 1
			
	if damage_part < MAX_PART_DAMAGE:
		parts[randi() % parts.size()].visible = false







