extends Control

signal on_resupply(_ok)

onready var _icon = $Panel/HBoxContainer/VBoxContainer/icon
onready var _weapon_name = $Panel/HBoxContainer/VBoxContainer/weapon_name
onready var _cost = $Panel/HBoxContainer/VBoxContainer/cost

onready var _button_resupply = $Panel/HBoxContainer/btn_resupply/btn_resupply

var weapon = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_check_resupply_status()

func _check_resupply_status():
	_icon.texture = load(weapon.icon)
	_weapon_name.text = weapon.name
	_cost.text = "Cost : $" + str((weapon.max_ammo - weapon.ammo) * weapon.ammo_cost)
	_button_resupply.modulate = Color(0.670588, 0.498039, 0.039216) if (weapon.ammo < weapon.max_ammo) else Color.gray
	_button_resupply.disabled = (weapon.ammo == weapon.max_ammo)


func _on_btn_resupply_pressed():
	if Global.player_data.cash - ((weapon.max_ammo - weapon.ammo) * weapon.ammo_cost) < 0:
		emit_signal("on_resupply", false)
		return
		
	Global.player_data.cash = Global.player_data.cash - ((weapon.max_ammo - weapon.ammo) * weapon.ammo_cost)
	Global.save_player_data()
	
	weapon.ammo = weapon.max_ammo
	Global.save_player_selected_ship()
	
	_check_resupply_status()
	emit_signal("on_resupply", true)
