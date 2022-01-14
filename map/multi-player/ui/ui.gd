extends Control

signal on_shot_press(_index)
signal on_aim_mode(_aim_mode)
signal on_respawn_click()

onready var _deadscreen = $CanvasLayer/Control2/deadscreen
onready var _ui_control = $CanvasLayer/Control2/Control
onready var _hp_bar = $CanvasLayer/Control2/Control/mid/hp_bar
onready var _weapons_bar = $CanvasLayer/Control2/Control/mid/VBoxContainer

var _aim_mode = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _on_aim_pressed():
	_aim_mode = not _aim_mode
	emit_signal("on_aim_mode" ,_aim_mode)
	
func _on_VBoxContainer_on_item_press(index, data):
	emit_signal("on_shot_press" , index)
	
func _on_battle_player_on_ready(player):
	_ui_control.visible = true
	_deadscreen.visible = false
	_hp_bar.update_bar(player.hp, player.max_hp)
	_weapons_bar.datas = player.weapons
	_weapons_bar.update_list()
	
func _on_player_on_take_damage(player, damage, hp):
	_hp_bar.update_bar(hp,player.max_hp)
	
func _on_player_on_destroyed(player):
	_ui_control.visible = false
	_deadscreen.visible = true
	
func _on_player_on_falling(player):
	_aim_mode = false
	_ui_control.visible = false
	emit_signal("on_aim_mode" ,_aim_mode)
	
func _on_deadscreen_on_respawn_click():
	emit_signal("on_respawn_click")
