extends Ship

onready var _part = $pivot
onready var _tween = $Tween
onready var _tween2 = $Tween2
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
		
	_tween2.interpolate_property(self,"translation",translation, _puppet_translation, 0.1)
	_tween2.start()
	
func _set_puppet_rotation(_val:Vector3):
	._set_puppet_rotation(_val)
	if destroyed:
		rotation = _puppet_rotation
		return
		
remotesync func _take_damage(damage):
	._take_damage(damage)
	
	if destroyed:
		return
	
	update_hp_bar()
	
###############################################################


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

	
func set_hp_bar_name(player_name):
	.set_hp_bar_name(player_name)
	_hp_bar.set_player_name(player_name)
	
	
func show_hp_bar(_show : bool):
	.show_hp_bar(_show)
	_hp_bar.visible = _show
		
func highlight(_show : bool):
	if destroyed:
		return
		
	_highlight.highlight(_show)
	
	
func set_skin(_camo : String = ""):
	$pivot/body_1.texture = load("res://skin/ships/baloons/"+ _camo + "/" +"baloon.png")
	$pivot/body_2.texture = load("res://skin/ships/baloons/"+ _camo + "/" +"baloon.png")
	$pivot/bridge_1.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_2.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_3.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_4.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_5.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_6.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_7.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_8.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	
	
	
func destroy():
	.destroy()
	_hp_bar.visible = false
	_highlight.visible = false
	_tween.connect("tween_completed", self ,"_on_Tween_tween_completed")
	_tween.interpolate_property(self, "translation", translation, Vector3(translation.x, 1.0, translation.y), 5.0)
	_tween.start()
	
func restock_ammo(weapon_slot, ammo_restock):
	.restock_ammo(weapon_slot, ammo_restock)
	
func _on_Tween_tween_completed(object, key):
	if not destroyed:
		return
		
	if str(key) == ":translation":
		.spawn_explosive_on_destroy()
		
	
func play_sound(path : String):
	.play_sound(path)
#	_audio.stream = load(path)
#	_audio.play()

func update_hp_bar():
	.update_hp_bar()
	_hp_bar.update_bar(hp,max_hp)
	

