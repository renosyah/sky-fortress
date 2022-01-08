extends Sprite3D

onready var _viewport_hp_bar = $Viewport
onready var _2d_hp_bar = $Viewport/hp_bar

func _ready():
	texture = _viewport_hp_bar.get_texture()
	
func set_bar(hp,max_hp):
	_2d_hp_bar.max_value = max_hp
	_2d_hp_bar.value = hp
	
func update_bar(hp, max_hp):
	_2d_hp_bar.update_bar(hp, max_hp)
	
func set_hp_bar_color(_color : Color):
	_2d_hp_bar.set_hp_bar_color(_color)
