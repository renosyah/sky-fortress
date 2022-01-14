extends Control

signal on_respawn_click()
signal on_spectate_click()

onready var _bg = $bg
onready var _screen = $CenterContainer
onready var _killedby = $CenterContainer/VBoxContainer/killedby

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func show_deadscreen(_is_show : bool, _killed_by : String = ""):
	visible = _is_show
	_screen.visible = _is_show
	_killedby.text = "Killed By " + _killed_by
	
	
func _on_respawn_pressed():
	emit_signal("on_respawn_click")
	
	
func _on_spectate_pressed():
	emit_signal("on_spectate_click")
