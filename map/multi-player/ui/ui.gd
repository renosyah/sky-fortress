extends Control

const MAX_CHAT_LOG = 4

signal on_shot_press(_index)
signal on_aim_mode(_aim_mode)
signal on_exit_click()
signal on_next_click()
signal on_prev_click()

onready var _minimap = $CanvasLayer/Control2/Control/left/MiniMap
onready var _spectatescreen = $CanvasLayer/Control2/spectate
onready var _deadscreen = $CanvasLayer/Control2/deadscreen
onready var _ui_control = $CanvasLayer/Control2/Control
onready var _hp_bar = $CanvasLayer/Control2/Control/mid/hp_bar
onready var _weapons_bar = $CanvasLayer/Control2/Control/mid/VBoxContainer

onready var _chat_window = $CanvasLayer/Control2/chating
onready var _chat_log = $CanvasLayer/Control2/Control/left/chat_log

onready var _tween = $CanvasLayer/Tween

var _aim_mode = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#_weapons_bar.visible = false
	pass
	
func set_camera(object : Spatial):
	_minimap.set_camera(object)
	
func add_minimap_object(object : Spatial):
	_minimap.add_object(object)
	
func remove_minimap_object(object : Spatial):
	_minimap.remove_object(object)
	
func set_spectating_name(nm : String):
	_spectatescreen.set_spectating_name(nm)
	
func _on_aim_pressed():
	_aim_mode = not _aim_mode
	#_weapons_bar.visible = _aim_mode
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
	emit_signal("on_aim_mode", false)
	
func _on_deadscreen_on_spectate_click():
	_ui_control.visible = false
	_deadscreen.visible = false
	_spectatescreen.visible = true
	
func _on_spectate_on_exit_click():
	emit_signal("on_exit_click")

func _on_exit_pressed():
	emit_signal("on_exit_click")

func _on_spectate_on_next_click():
	emit_signal("on_next_click")
	
func _on_spectate_on_prev_click():
	emit_signal("on_prev_click")
	
func _on_chat_button_pressed():
	_chat_window.visible = true

func _on_chat_on_message(_message, _from):
	if _chat_log.get_child_count() > MAX_CHAT_LOG:
		_chat_log.remove_child(_chat_log.get_child(0))
		
	var chat_item = preload("res://assets/ui/chat/item/item.tscn").instance()
	chat_item.text = "("+ _from +") : " + _message
	_chat_log.add_child(chat_item)
	
	_tween.interpolate_property(_chat_log, "modulate:a", 1.0, 0.0, 5.0)
	_tween.start()

func _on_close_chat_pressed():
	_chat_window.visible = false



