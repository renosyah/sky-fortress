extends Control

signal pressed

onready var _selected_bg = $ColorRect
onready var _icon = $TextureRect
onready var _text = $PanelContainer/CenterContainer/Label
onready var _input_detection = $inputDetection

var data = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func display_item():
	if data.has("name"):
		_text.text = data.name
		
	if data.has("icon"):
		_icon.texture = load(data.icon)
	
func selected(_selected):
	_selected_bg.color = Color.white if _selected else Color.black
	
func _on_item_gui_input(event):
	if event is InputEventMouseButton and event.is_action_pressed("left_click"):
		emit_signal("pressed")
		
	_input_detection.check_input(event)
	
func _on_inputDetection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("pressed")
	
