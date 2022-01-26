extends Control

signal on_exit_click
signal on_prev_click
signal on_next_click

onready var _name = $VBoxContainer/CenterContainer/VBoxContainer/message

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func set_spectating_name(nm : String):
	_name.text = "[ "+ nm +" ]"
	
func _on_exit_pressed():
	emit_signal("on_exit_click")


func _on_next_pressed():
	emit_signal("on_next_click")


func _on_next2_pressed():
	emit_signal("on_prev_click")
