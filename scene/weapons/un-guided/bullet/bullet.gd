extends Spatial

var speed = 25.0
var _velocity : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)

func _process(delta):
	translation += _velocity * speed * delta
	
func lauching_at(to: Vector3):
	_velocity = translation.direction_to(to)
	
func _on_VisibilityNotifier_screen_exited():
	queue_free()
