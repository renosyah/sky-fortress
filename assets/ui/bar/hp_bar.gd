extends Control

onready var _hp_bar = $hp_bar
onready var _hp_bar_bg = $hp_bar_bg
onready var _tween = $Tween
onready var _label = $RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func show_label(_show = true):
	_label.visible = _show

func update_bar(hp, max_hp):
	if max_hp > 100.0:
		_hp_bar_bg.step = 1.0
		_hp_bar.step = 1.0
		
	if max_hp < 50.0:
		_hp_bar_bg.step = 0.5
		_hp_bar.step = 0.5
		
	if max_hp < 10.0:
		_hp_bar_bg.step = 0.1
		_hp_bar.step = 0.1
		
	_label.text = str(hp) + "/" + str(max_hp)
	_hp_bar_bg.max_value = max_hp
	_tween.interpolate_property(_hp_bar_bg, "value", _hp_bar_bg.value, hp, Tween.TRANS_SINE, Tween.EASE_IN)
	_tween.start()
	
	_hp_bar.max_value = max_hp
	if hp > _hp_bar.value:
		_tween.interpolate_property(_hp_bar, "value", _hp_bar.value, hp, Tween.TRANS_SINE, Tween.EASE_IN)
		_tween.start()
		return
	
	_hp_bar.value = hp
	
func set_hp_bar_color(_color : Color):
	_hp_bar.tint_progress = _color
