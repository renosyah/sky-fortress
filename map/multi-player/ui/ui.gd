extends Control

signal on_aim_mode(_aim_mode)

var _aim_mode = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_aim_pressed():
	_aim_mode = not _aim_mode
	emit_signal("on_aim_mode" ,_aim_mode)
