extends Spatial

signal on_finish_explode()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("on_finish_explode")
	queue_free()
