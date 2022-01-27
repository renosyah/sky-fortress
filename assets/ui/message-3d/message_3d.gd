extends Sprite3D

const MAX_DISTANCE = 15.0

onready var _message = $Viewport/VBoxContainer/message
onready var _viewport = $Viewport

var max_distance

var speed = 1.8
var _velocity : Vector3
var _travel_distance : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = _viewport.get_texture()
	set_as_toplevel(true)
	
func _process(delta):
	var _distance = speed * delta
	translation.y += _distance
	_travel_distance += _distance
	
	if _travel_distance > MAX_DISTANCE:
		set_process(false)
		queue_free()
		
func set_color(_color : Color):
	_message.modulate = _color
	
func set_message(_msg):
	_message.text = _msg
