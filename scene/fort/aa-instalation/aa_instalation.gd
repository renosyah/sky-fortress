extends Fort

onready var _part = $pivot
onready var _hp_bar = $hpBar
onready var _audio = $AudioStreamPlayer3D
onready var _highlight = $highlight
onready var _input_detection = $inputDetection
onready var _pivot = $pivot
onready var _tween = $Tween

###############################################################
# multiplayer sync
remotesync func _take_damage(damage):
	._take_damage(damage)
	
	if destroyed:
		return
	
	update_hp_bar()
	
###############################################################

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	
	_highlight.highlight(false)
	
	if not is_connected("input_event", self , "_on_input_event"):
		connect("input_event", self , "_on_input_event")
		
	if not _input_detection.is_connected("any_gesture", self, "_on_inputDetection_any_gesture"):
		_input_detection.connect("any_gesture", self, "_on_inputDetection_any_gesture")
		
	_tween.interpolate_property(_pivot, "translation:y", -3, 0, 3.0)
	_tween.start()
		
	update_hp_bar()
	
func highlight(_show : bool):
	if destroyed:
		return
		
	_highlight.highlight(_show)
	
func set_hp_bar_color(_color : Color):
	.set_hp_bar_color(_color)
	_hp_bar.set_hp_bar_color(_color)
	
func show_hp_bar(_show : bool):
	.show_hp_bar(_show)
	_hp_bar.visible = _show
	
func set_hp_bar_name(player_name):
	.set_hp_bar_name(player_name)
	_hp_bar.set_player_name(player_name)
	
func take_damage(damage):
	.take_damage(damage)
	
	if destroyed:
		return
		
	update_hp_bar()
	
func destroy():
	.destroy()
	_hp_bar.visible = false
	_highlight.highlight(false)
	
func restock_ammo(weapon_slot, ammo_restock):
	.restock_ammo(weapon_slot, ammo_restock)
	
func play_sound(path : String):
	.play_sound(path)
#	_audio.stream = load(path)
#	_audio.play()
	
func update_hp_bar():
	.update_hp_bar()
	_hp_bar.update_bar(hp,max_hp)
	
func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.is_action_pressed("left_click"):
		emit_signal("on_click", self)
		
	_input_detection.check_input(event)
	
	
func _on_inputDetection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_click", self)
	


