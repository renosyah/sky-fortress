extends Sprite3D

onready var _timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func show():
	visible = true
	_timer.start()
	
func _on_Timer_timeout():
	visible = false
