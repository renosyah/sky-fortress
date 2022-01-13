extends Ship

const MAX_PART_DAMAGE = 3

onready var _part = $pivot
onready var _tween = $Tween
onready var _hp_bar = $hpBar
onready var _audio = $AudioStreamPlayer3D
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
	
###############################################################



func make_ready():
	.make_ready()
	_ready()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()

	for i in _part.get_children():
		i.visible = true
		
	_highlight.highlight(false)
	update_hp_bar()
	show_hp_bar(false)
	
func set_hp_bar_color(_color : Color):
	.set_hp_bar_color(_color)
	_hp_bar.set_hp_bar_color(_color)
	
func show_hp_bar(_show : bool):
	.show_hp_bar(_show)
	_hp_bar.visible = _show
	
func take_damage(damage):
	.take_damage(damage)
	
	if destroyed:
		return
	
	update_hp_bar()
	
	if damage > 15.0:
		_damage_random_part()
		
func highlight(_show : bool):
	if destroyed:
		return
		
	_highlight.highlight(_show)
	
func destroy():
	.destroy()
	_hp_bar.visible = false
	_highlight.visible = false
	_tween.interpolate_property(self, "translation", translation, Vector3(translation.x, 1.0, translation.y), rand_range(4.0,8.0))
	_tween.start()
	
func restock_ammo(weapon_slot, ammo_restock):
	.restock_ammo(weapon_slot, ammo_restock)
	
func _on_Tween_tween_completed(object, key):
	if not destroyed:
		return
		
	if str(key) == ":translation":
		.spawn_explosive_on_destroy()
	
func _damage_random_part():
	var damage_part = 0
	var parts = _part.get_children()
	for i in parts:
		if i.visible == false:
			damage_part += 1
			
	if damage_part < MAX_PART_DAMAGE:
		parts[randi() % parts.size()].visible = false
	
func play_sound(path : String):
	.play_sound(path)
#	_audio.stream = load(path)
#	_audio.play()

func update_hp_bar():
	.update_hp_bar()
	_hp_bar.update_bar(hp,max_hp)
	

