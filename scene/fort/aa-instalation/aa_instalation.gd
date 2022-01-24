extends Fort

onready var _part = $pivot
onready var _hp_bar = $hpBar
onready var _audio = $AudioStreamPlayer3D
onready var _highlight = $highlight
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



