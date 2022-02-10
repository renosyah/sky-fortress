extends Control

signal on_repaired(_ok)
signal on_resupply(_ok)
signal on_apply_camo(_ok)

onready var _player_cash = $VBoxContainer/PanelContainer/HBoxContainer/margin2/name_button2/cash

onready var _service_page= $VBoxContainer/HBoxContainer2/HBoxContainer/service_page
onready var _upgrade_page = $VBoxContainer/HBoxContainer2/HBoxContainer/upgrade_page
onready var _depot_page = $VBoxContainer/HBoxContainer2/HBoxContainer/depot_page
onready var _market_page = $VBoxContainer/HBoxContainer2/HBoxContainer/market_page

onready var _repair_cost = $VBoxContainer/HBoxContainer2/HBoxContainer/service_page/VBoxContainer/repair_panel/Panel/HBoxContainer/VBoxContainer/cost
onready var _button_repair = $VBoxContainer/HBoxContainer2/HBoxContainer/service_page/VBoxContainer/repair_panel/Panel/HBoxContainer/btn_repair/btn_repair

onready var _armory_holder = $VBoxContainer/HBoxContainer2/HBoxContainer/service_page/VBoxContainer/VBoxContainer

onready var _apply_green_camo = $VBoxContainer/HBoxContainer2/HBoxContainer/service_page/VBoxContainer/paint_green_panel/Panel/HBoxContainer/btn_green_camo/btn_green_camo
onready var _apply_winter_camo = $VBoxContainer/HBoxContainer2/HBoxContainer/service_page/VBoxContainer/paint_winter_panel2/Panel/HBoxContainer/btn_winter_camo/btn_winter_camo
onready var _apply_default_camo = $VBoxContainer/HBoxContainer2/HBoxContainer/service_page/VBoxContainer/paint_default_panel3/Panel/HBoxContainer/btn_default_camo/btn_default_camo

func _ready():
	_player_cash.text = "$" + str(Global.player_data.cash)
	_check_repair_status()
	_check_armory_status()
	_check_green_camo_status()
	_check_winter_camo_status()
	_check_default_camo_status()

func make_ready():
	_ready()

func _check_repair_status():
	_repair_cost.text = "Cost : $" + str((Global.selected_ship.max_hp - Global.selected_ship.hp) * Global.selected_ship.repair_cost_per_hp)
	_button_repair.modulate = Color(0.670588, 0.498039, 0.039216) if (not Global.is_ship_ok()) else Color.gray
	_button_repair.disabled = Global.is_ship_ok()
	
func _check_green_camo_status():
	var _can_apply = Global.is_ship_ok() and Global.selected_ship.skin != "g-camo"
	_apply_green_camo.modulate = Color(0.670588, 0.498039, 0.039216) if _can_apply else Color.gray
	_apply_green_camo.disabled = not _can_apply
	
func _check_winter_camo_status():
	var _can_apply = Global.is_ship_ok() and Global.selected_ship.skin != "w-camo"
	_apply_winter_camo.modulate = Color(0.670588, 0.498039, 0.039216) if _can_apply else Color.gray
	_apply_winter_camo.disabled = not _can_apply
	
func _check_default_camo_status():
	var _can_apply = Global.is_ship_ok() and Global.selected_ship.skin != ""
	_apply_default_camo.modulate = Color(0.670588, 0.498039, 0.039216) if _can_apply else Color.gray
	_apply_default_camo.disabled = not _can_apply
	
	
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
	_ready()
	emit_signal("on_resupply", _ok)

func _on_btn_repair_pressed():
	if Global.player_data.cash - ((Global.selected_ship.max_hp - Global.selected_ship.hp) * Global.selected_ship.repair_cost_per_hp) < 0:
		emit_signal("on_repaired", false)
		return
		
	Global.player_data.cash = Global.player_data.cash - ((Global.selected_ship.max_hp - Global.selected_ship.hp) * Global.selected_ship.repair_cost_per_hp)
	Global.save_player_data()
	
	Global.selected_ship.hp = Global.selected_ship.max_hp
	Global.save_player_selected_ship()
	
	_player_cash.text = "$" + str(Global.player_data.cash)
	
	_ready()
	emit_signal("on_repaired", true)
	
func _on_btn_green_camo_pressed():
	if Global.player_data.cash - 150 < 0:
		emit_signal("on_apply_camo", false)
		return
		
	Global.player_data.cash -= 150
	Global.save_player_data()
	
	Global.selected_ship.skin = "g-camo"
	Global.save_player_selected_ship()
	
	_ready()
	emit_signal("on_apply_camo", true)
	
func _on_btn_winter_camo_pressed():
	if Global.player_data.cash - 150 < 0:
		emit_signal("on_apply_camo", false)
		return
		
	Global.player_data.cash -= 150
	Global.save_player_data()
	
	Global.selected_ship.skin = "w-camo"
	Global.save_player_selected_ship()
	
	_ready()
	emit_signal("on_apply_camo", true)
	
func _on_btn_default_camo_pressed():
	Global.selected_ship.skin = ""
	Global.save_player_selected_ship()
	
	_ready()
	emit_signal("on_apply_camo", true)













