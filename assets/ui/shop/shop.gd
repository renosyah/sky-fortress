extends Control

signal on_repaired(_ok)
signal on_resupply(_ok)

onready var _service_page= $VBoxContainer/HBoxContainer/service_page
onready var _upgrade_page = $VBoxContainer/HBoxContainer/upgrade_page
onready var _depot_page = $VBoxContainer/HBoxContainer/depot_page
onready var _market_page = $VBoxContainer/HBoxContainer/market_page

onready var _repair_cost = $VBoxContainer/HBoxContainer/service_page/VBoxContainer/repair_panel/Panel/HBoxContainer/VBoxContainer/cost
onready var _button_repair = $VBoxContainer/HBoxContainer/service_page/VBoxContainer/repair_panel/Panel/HBoxContainer/btn_repair/btn_repair

onready var _armory_holder = $VBoxContainer/HBoxContainer/service_page/VBoxContainer/VBoxContainer

func _ready():
	_check_repair_status()
	_check_armory_status()

func make_ready():
	_ready()

func _check_repair_status():
	_repair_cost.text = "Cost : $" + str((Global.selected_ship.max_hp - Global.selected_ship.hp) * Global.selected_ship.repair_cost_per_hp)
	_button_repair.modulate = Color(0.670588, 0.498039, 0.039216) if (not Global.is_ship_ok()) else Color.gray
	_button_repair.disabled = Global.is_ship_ok()
	
func _check_armory_status():
	for i in _armory_holder.get_children():
		_armory_holder.remove_child(i)
		
	for i in Global.selected_ship.weapons:
		var item = preload("res://assets/ui/shop/armory-item/item.tscn").instance()
		item.weapon = i
		item.connect("on_resupply", self, "_on_resupply")
		_armory_holder.add_child(item)
	
func _on_exit_pressed():
	visible = false

func hide_all():
	_service_page.visible = false
	_upgrade_page.visible = false
	_depot_page.visible = false
	_market_page.visible = false

func _on_btn_service_pressed():
	hide_all()
	_service_page.visible = true


func _on_btn_upgrade_pressed():
	hide_all()
	_upgrade_page.visible = true


func _on_btn_depot_pressed():
	hide_all()
	_depot_page.visible = true


func _on_btn_market_pressed():
	hide_all()
	_market_page.visible = true

func _on_resupply(_ok):
	emit_signal("on_resupply", _ok)

func _on_btn_repair_pressed():
	if Global.player_data.cash - ((Global.selected_ship.max_hp - Global.selected_ship.hp) * Global.selected_ship.repair_cost_per_hp) < 0:
		emit_signal("on_repaired", false)
		return
		
	Global.selected_ship.hp = Global.selected_ship.max_hp
	Global.save_player_selected_ship()
	Global.update_player_ships(Global.selected_ship)
	
	Global.player_data.cash -= ((Global.selected_ship.max_hp - Global.selected_ship.hp) * Global.selected_ship.repair_cost_per_hp)
	Global.save_player_data()
	
	_check_repair_status()
	emit_signal("on_repaired", true)








