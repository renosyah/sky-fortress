extends PanelContainer

onready var _player_name = $VBoxContainer/HBoxContainer/VBoxContainer/player_name
onready var _ship_name = $VBoxContainer/HBoxContainer/VBoxContainer/player_ship
onready var _icon = $VBoxContainer/HBoxContainer/icon

onready var _hp_bar = $VBoxContainer/HBoxContainer/VBoxContainer/player_hp_bar

var player_id = ""
var player_name = ""
var player_ship_name = ""
var player_ship_icon = ""
var hp = 0.0
var max_hp = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	_player_name.text = player_name
	_ship_name.text = player_ship_name
	_icon.texture = load(player_ship_icon)
	update_bar(hp, max_hp)

func update_bar(_hp, _max_hp):
	_hp_bar.update_bar(_hp, _max_hp)
