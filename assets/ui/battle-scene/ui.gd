extends Control

signal on_shot_press(_index)
signal on_aim_press(_is_press)
signal on_respawn_click()

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/Control2/Control/mid/HBoxContainer.visible = false
	
func set_camera(object : Spatial):
	$CanvasLayer/Control2/Control/left/MiniMap.set_camera(object)
	
func add_minimap_object(object : Spatial):
	$CanvasLayer/Control2/Control/left/MiniMap.add_object(object)
	
func remove_minimap_object(object : Spatial):
	$CanvasLayer/Control2/Control/left/MiniMap.remove_object(object)
	
func _on_aim_toggled(button_pressed):
	emit_signal("on_aim_press", button_pressed)
	$CanvasLayer/Control2/Control/mid/HBoxContainer.visible = button_pressed
	
	
func _on_lock_on_pressed():
		emit_signal("on_shot_press" , 2)
	
	
func _on_guided_pressed():
		emit_signal("on_shot_press" , 1)
	
	
func _on_cannon_pressed():
		emit_signal("on_shot_press" , 0)
	
	
func _on_player_on_take_damage(_node, damage, hp):
	$CanvasLayer/Control2/Control/mid/hp_bar.max_value = _node.max_hp
	$CanvasLayer/Control2/Control/mid/hp_bar.value = hp
	
func _on_player_on_ready(_node):
	$CanvasLayer/Control2/Control.visible = true
	$CanvasLayer/Control2/deadscreen.visible = false
	$CanvasLayer/Control2/Control/mid/hp_bar.max_value = _node.max_hp
	$CanvasLayer/Control2/Control/mid/hp_bar.value = _node.hp
	
func _on_player_on_destroyed(_node):
	$CanvasLayer/Control2/Control.visible = false
	$CanvasLayer/Control2/deadscreen.visible = true
	
	
func _on_deadscreen_on_respawn_click():
	$CanvasLayer/Control2/Control.visible = true
	$CanvasLayer/Control2/deadscreen.visible = false
	emit_signal("on_respawn_click")
	
	
func _on_player_on_falling(_node):
	_on_aim_toggled(false)
	$CanvasLayer/Control2/Control.visible = false
	


