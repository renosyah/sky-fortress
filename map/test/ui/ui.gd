extends Control

signal on_shot_press(_index)
signal on_aim_press(_is_press)
signal on_respawn_click()

var toggled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/Control2/Control/mid/VBoxContainer.visible = false
	
func set_camera(object : Spatial):
	$CanvasLayer/Control2/Control/left/MiniMap.set_camera(object)
	
func add_minimap_object(object : Spatial):
	$CanvasLayer/Control2/Control/left/MiniMap.add_object(object)
	
func remove_minimap_object(object : Spatial):
	$CanvasLayer/Control2/Control/left/MiniMap.remove_object(object)
	
func _on_aim_pressed():
	toggled = !toggled
	emit_signal("on_aim_press", toggled)
	$CanvasLayer/Control2/Control/mid/VBoxContainer.visible = toggled
	
	
func _on_VBoxContainer_on_item_press(index, data):
	emit_signal("on_shot_press" , index)
	
func _on_player_on_take_damage(_node, damage, hp):
	$CanvasLayer/Control2/Control/mid/hp_bar.update_bar(hp, _node.max_hp)
	
func _on_battlescene_player_on_ready(_node):
	$CanvasLayer/Control2/Control.visible = true
	$CanvasLayer/Control2/deadscreen.visible = false
	$CanvasLayer/Control2/Control/mid/hp_bar.update_bar(_node.hp, _node.max_hp)
	$CanvasLayer/Control2/Control/mid/VBoxContainer.datas = _node.weapons
	$CanvasLayer/Control2/Control/mid/VBoxContainer.update_list()
	
func _on_player_on_destroyed(_node):
	$CanvasLayer/Control2/Control.visible = false
	$CanvasLayer/Control2/deadscreen.visible = true
	
func _on_deadscreen_on_respawn_click():
	$CanvasLayer/Control2/Control.visible = false
	$CanvasLayer/Control2/deadscreen.visible = false
	
func _on_deadscreen_on_spectate_click():
	$CanvasLayer/Control2/Control.visible = false
	$CanvasLayer/Control2/deadscreen.visible = false
	
func _on_player_on_falling(_node):
	toggled = false
	emit_signal("on_aim_press", toggled)
	$CanvasLayer/Control2/Control/mid/VBoxContainer.visible = toggled
	$CanvasLayer/Control2/Control.visible = toggled
	
func _on_exit_pressed():
	_on_quit_pressed()
	
	
func _on_quit_pressed():
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")








