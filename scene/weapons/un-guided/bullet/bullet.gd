extends Spatial

const MAX_DISTANCE = 15.0

var speed = 25.0
var _velocity : Vector3
var _travel_distance : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)

func _process(delta):
	var _distance = speed * delta
	translation += _velocity * _distance
	_travel_distance += _distance
	
	if _travel_distance > MAX_DISTANCE:
		set_process(false)
		queue_free()
	
func lauching_at(to: Vector3, dis : float = MAX_DISTANCE):
	_velocity = translation.direction_to(to)
	look_at(to, Vector3.UP)
