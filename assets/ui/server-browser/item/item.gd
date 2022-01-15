extends Control

signal join(info)

onready var _label = $Panel/HBoxContainer/Label

var info = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	if info.empty():
		return
	
	_label.text = info.name
	
func _on_btn_pressed():
	emit_signal("join", info)
