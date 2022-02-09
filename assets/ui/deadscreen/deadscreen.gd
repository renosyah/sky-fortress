extends Control

signal on_spectate_click()

onready var _timer = $Timer
onready var _spectate_countdown = $CenterContainer/VBoxContainer/spectate_text

func _ready():
	set_process(false)

func show_deadscreen():
	_timer.wait_time = 5.0
	_timer.start()
	set_process(true)
	
	
func _process(delta):
	_spectate_countdown.text = "Spectate in " + str(int(_timer.time_left)) + "..."
	
	
func _on_Timer_timeout():
	emit_signal("on_spectate_click")
	set_process(false)
