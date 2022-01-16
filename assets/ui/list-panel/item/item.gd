extends Button

onready var _selected_bg = $ColorRect
onready var _icon = $TextureRect
onready var _text = $Label

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
