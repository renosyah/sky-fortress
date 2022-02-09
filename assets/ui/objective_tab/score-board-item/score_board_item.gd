extends PanelContainer

onready var _player_name = $VBoxContainer/HBoxContainer/VBoxContainer/player_name
onready var _ship_name = $VBoxContainer/HBoxContainer/VBoxContainer/player_ship
onready var _icon = $VBoxContainer/HBoxContainer/icon

onready var _kill_count = $VBoxContainer/HBoxContainer/kill_count
onready var _cash_count = $VBoxContainer/HBoxContainer/cash_count

var player_id = ""
var player_name = ""
var player_ship_name = ""
var player_ship_icon = ""
var kill_count = 0
var cash_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_player_name.text = player_name
	_ship_name.text = player_ship_name
	_icon.texture = load(player_ship_icon)
	
	_kill_count.text = "Kill : " + str(kill_count)
	_cash_count.text = "Cash : $" + str(cash_count)
	
	
func update_score(kill_add, cash_add : int):
	kill_count += kill_add
	cash_count += cash_add
	
	_kill_count.text = "Kill : " + str(kill_count)
	_cash_count.text = "Cash : $" + str(cash_count)
