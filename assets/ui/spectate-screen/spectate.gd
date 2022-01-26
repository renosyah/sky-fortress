extends Control

signal on_exit_click
signal on_prev_click
signal on_next_click

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _on_exit_pressed():
	emit_signal("on_exit_click")


func _on_next_pressed():
	emit_signal("on_next_click")


func _on_next2_pressed():
	emit_signal("on_prev_click")
