extends Sprite3D
	
onready var _tween = $Tween
	
var is_move = false
var speed = 5.0
var from_right = true
	
# Called when the node enters the scene tree for the first time.
func _ready():
	opacity = 0.0
	_tween.interpolate_property(self, "opacity", 0.0 ,1.0, 8.0)
	_tween.start()
	
func set_opacity(val):
	modulate.a = val

func random_scale():
	var _scale = randf() + rand_range(2.5,4.5)
	scale = Vector3(_scale,_scale,_scale)

func random_speed():
	speed = randf() + rand_range(3,8)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_move:
		if from_right:
			translation.x -= speed * delta
		else:
			translation.x += speed * delta
		
		
func _on_VisibilityNotifier_screen_exited():
	if is_move:
		queue_free()
	
	
	
	
