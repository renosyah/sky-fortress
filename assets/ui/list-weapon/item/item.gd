extends HBoxContainer

signal pressed(index, data)

onready var _icon = $button/TextureRect
onready var _text = $button/PanelContainer/VBoxContainer/Label
onready var _ammo = $button/PanelContainer/VBoxContainer/Label2
onready var _cooldown = $cooldown
onready var _progress = $button/TextureProgress
onready var _enable = $button/TextureRect2
onready var _button = $button

var index = 0
var data = {}
var clickable = true

var _holded = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func display_item():
	if data.has("name"):
		_text.text = data.name
		
	if data.has("ammo"):
		_ammo.text = str(data.ammo)
		
	if data.has("icon"):
		_icon.texture = load(data.icon)
		
	if data.has("cool_down"):
		_progress.max_value = data.cool_down
		_progress.value = 0.0
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not clickable:
		return
		
	if data.has("ammo") and data.has("can_fire"):
		_ammo.text = str(data.ammo)
		_enable.visible = data.ammo == 0 or not data.can_fire
		
	if _cooldown.is_stopped() and not _holded:
		return
		
	if _cooldown.is_stopped() and _holded:
		_cooldown.wait_time = data.cool_down
		_cooldown.start()
		emit_signal("pressed",index, data)
		
	_progress.max_value = data.cool_down
	_progress.value = _cooldown.time_left
	
	
func _on_button_pressed():
	if not clickable:
		return
		
	if not data.can_fire:
		return
		
	if data.ammo <= 0:
		return
		
	if not _cooldown.is_stopped():
		return
		
	_cooldown.wait_time = data.cool_down
	_cooldown.start()
	
	emit_signal("pressed",index, data)


func _on_button_button_down():
	if not clickable:
		return
		
	if not data.can_fire:
		return
		
	if data.ammo <= 0:
		return
		
	_holded = true
	
	
func _on_button_button_up():
	_holded = false
	

