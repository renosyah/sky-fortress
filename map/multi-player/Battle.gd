extends Node
class_name MP_Battle

const HOSTILE_SIDE = "BOT"
const PLAYER_SIDE = "player"

signal player_on_ready(player)

# player node
var _player : KinematicBody

# player targeting system
var _aim_point : Vector3
var _player_aim_guider : Spatial
var _lock_on_point : Spatial

# for every targetable airborne node
# but because this MP mode is COOP
# only players object are targetable by bots
var _airborne_targets = []

# misc
var _aim_mode = false
var _spectate_mode = false
var _spectate_cicle_pos = 0

# mission
var _max_hostile_ship = 0
var _max_hostile_fort = 0
var _aggresion = 0.0
var _min_crate = 0
var _max_crate = 0
var _min_cash = 100
var _max_cash = 250

################################################################
# network connection watcher
# for both client and host
func init_connection_watcher():
	Network.connect("server_disconnected", self , "_server_disconnected")
	Network.connect("connection_closed", self , "_connection_closed")
	
func _connection_closed():
	print("exit by Client!")
	
func _server_disconnected():
	Global.mp_exception_message = "Unexpected exit by Server!"
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
remotesync func _disconnect_from_server():
	if not get_tree().is_network_server():
		Network.disconnect_from_server()
	
func disconnect_from_server():
	rpc("_disconnect_from_server")
	
################################################################
# client request terrain data section
# and receive terrain data section
remote func _request_terrain_data(
	from_id : int
):
	pass
	
remote func _receive_terrain_data(
	unused_translations :Array,
	feature_translations :Array,
	features :Array,
	season : String
):
	pass
	
################################################################
# request object to move
remote func _move(node_path : NodePath, translation : Vector3):
	var _node = get_node_or_null(node_path)
	if not is_instance_valid(_node):
		return
		
	_node.waypoint = translation
	
################################################################
# client request to object to
# move at guided aim position
remotesync func _guide_aim(node_path : NodePath, translation : Vector3):
	var _node = get_node_or_null(node_path)
	if not is_instance_valid(_node):
		return
		
	_node.translation = translation
	_node.translation.y = 10.0
	

# request to object to
# move at guided aim position
remotesync func _aim(node_path : NodePath, translation : Vector3):
	var _node = get_node_or_null(node_path)
	if not is_instance_valid(_node):
		return
		
	_node.aim_point = translation
	

# request to object to
# lock on target node
remotesync func _lock_on(node_path : NodePath, node_path_target : NodePath):
	var _node = get_node_or_null(node_path)
	if not is_instance_valid(_node):
		return
		
	var _node_target = get_node_or_null(node_path_target)
	if not is_instance_valid(_node_target):
		return
		
	_node.lock_on_point = _node_target
	
################################################################
# on object added to game
func add_minimap_object(_node_path : NodePath, _name : String = ""):
	pass
	
func remove_minimap_object(_node_path : NodePath):
	pass
	
################################################################
# player airship spawner manager
func spawn_players(_player_holder_path : NodePath, _targeting_guide_holder_path : NodePath, _ui_path : NodePath):
	var _player_holder = get_node_or_null(_player_holder_path)
	if not is_instance_valid(_player_holder):
		return
		
	var _targeting_guide_holder = get_node_or_null(_targeting_guide_holder_path)
	if not is_instance_valid(_targeting_guide_holder):
		return
		
	var _ui = get_node_or_null(_ui_path)
	if not is_instance_valid(_ui):
		return
		
	var spawn_pos = Vector3(0, 10, 0)
	for i in Global.mp_players_data:
		var spatial_target = Spatial.new()
		_targeting_guide_holder.add_child(spatial_target)
		spatial_target.name = "PLAYER-TARGET-" + i.owner_id
		spatial_target.translation = spawn_pos
		
		var ship = load(i.scene).instance()
		_player_holder.add_child(ship)
		ship.owner_id = i.owner_id
		ship.side = PLAYER_SIDE
		ship.name = "PLAYER-" + i.owner_id
		ship.set_network_master(Network.PLAYER_HOST_ID)
		ship.translation = spawn_pos
		ship.aim_point = spatial_target.translation
		ship.guided_point = spatial_target
		ship.set_data(i)
		ship.show_hp_bar(true)
		ship.set_hp_bar_name(i.player_name)
		ship.set_hp_bar_color(Color.blue)
		ship.MINIMAP_COLOR = Color.blue
		ship.update_hp_bar()
		ship.connect("on_destroyed",self,"_on_player_on_destroyed")
		
		if ship.owner_id == Global.player_data.id:
			_player = ship
			_player_aim_guider = spatial_target
			ship.MINIMAP_COLOR = Color.green
			
		add_minimap_object(ship.get_path(),i.player_name)
		spawn_pos.x += 5.0
		
	if not is_instance_valid(_player):
		return
		
	_player.show_hp_bar(false)
	_player.set_hp_bar_color(Color.green)
	
	_player.connect("on_move", self, "_on_player_on_move")
	_player.connect("on_destroyed",_ui,"_on_player_on_destroyed")
	_player.connect("on_falling",self,"_on_player_on_falling")
	_player.connect("on_falling",_ui,"_on_player_on_falling")
	_player.connect("on_spawning_weapon" ,self,"_on_airship_on_spawning_weapon")
	_player.connect("on_take_damage",_ui,"_on_player_on_take_damage")
	
	if get_tree().is_network_server():
		_airborne_targets.append_array(_player_holder.get_children())
	
################################################################
# hostile airship and fort manager
remotesync func _spawn_hostile_airship(player_network_unique_id:int, name:String, ship_data :Dictionary, holder_path:NodePath, ui_path:NodePath, _spawn_pos:Vector3):
	var holder = get_node_or_null(holder_path)
	if not is_instance_valid(holder):
		return
		
	var ui = get_node_or_null(ui_path)
	if not is_instance_valid(ui):
		return
		
	var ship = load(ship_data.scene).instance()
	var color = Color.red
	
	ship.owner_id = HOSTILE_SIDE
	ship.side = HOSTILE_SIDE
	ship.name = name
	ship.set_data(ship_data)
	ship.set_network_master(player_network_unique_id)
	ship.MINIMAP_COLOR = color
	holder.add_child(ship)
	
	ship.translation = _spawn_pos
	ship.translation.y = Ship.DEFAULT_ALTITUDE
	ship.show_hp_bar(true)
	ship.set_hp_bar_name(ship_data.name)
	ship.set_hp_bar_color(color)
	ship.connect("on_click", self ,"_on_enemy_click")
	ship.connect("on_spawning_weapon", self, "_on_enemy_on_spawning_weapon")
	ship.connect("on_destroyed", self, "_on_enemy_ship_on_destroyed")
	
	add_minimap_object(ship.get_path(), ship_data.name)
	
remotesync func _spawn_hostile_fort(player_network_unique_id:int, name:String, fort_data:Dictionary, holder_path:NodePath, ui_path:NodePath, _spawn_pos:Vector3):
	var holder = get_node_or_null(holder_path)
	if not is_instance_valid(holder):
		return
		
	var ui = get_node_or_null(ui_path)
	if not is_instance_valid(ui):
		return
		
	var fort = load(fort_data.scene).instance()
	var color = Color.red #Color(randf(),randf(),randf(), 1)
	
	fort.owner_id = HOSTILE_SIDE
	fort.side = HOSTILE_SIDE
	fort.name = name
	fort.set_data(fort_data)
	fort.set_network_master(player_network_unique_id)
	fort.MINIMAP_COLOR = color
	fort.targets = _airborne_targets
	holder.add_child(fort)
	
	fort.translation = _spawn_pos
	fort.translation.y = 1.0
	fort.show_hp_bar(true)
	fort.set_hp_bar_name(fort_data.name)
	fort.set_hp_bar_color(color)
	fort.connect("on_click", self ,"_on_enemy_click")
	fort.connect("on_spawning_weapon", self, "_on_enemy_on_spawning_weapon")
	fort.connect("on_destroyed", self, "_on_enemy_fort_on_destroyed")
	
	add_minimap_object(fort.get_path(), fort_data.name)
	
remotesync func _despawn_hostile_airship(node_path : NodePath):
	var _node = get_node_or_null(node_path)
	if not is_instance_valid(_node):
		return
		
	if get_tree().is_network_server():
		var qty = rand_range(_min_crate,_max_crate)
		var content_type = FlyingCrate.CONTENTS[randi() % FlyingCrate.CONTENTS.size()]
		rpc("_spawn_supply_crate", Network.PLAYER_HOST_ID, "SUPPLY-" + str(GDUUID.v4()) , content_type, qty, _node.translation)
		
	_node.queue_free()
	
remotesync func _remove_all_hostile(holder_paths: Array):
	for holder_path in holder_paths:
		var holder = get_node_or_null(holder_path)
		if not is_instance_valid(holder):
			return
			
		for i in holder.get_children():
			i.queue_free()
	
################################################################
# supply crate spawn and manager 
remotesync func _spawn_supply_crate(player_network_unique_id:int, name:String,content_type : String, max_crate : int, translation : Vector3):
	for i in max_crate:
		var crate = preload("res://scene/crates/flying-crate/crate.tscn").instance()
		crate.tag_color = Color.orange
		crate.translation = Vector3(rand_range(-5.0, 5.0), 0.0, rand_range(-5.0, 5.0)) + translation
		crate.translation.y = 2.0
		crate.owner_id = HOSTILE_SIDE
		crate.side = HOSTILE_SIDE
		crate.name = name +"-"+ str(i)
		crate.content_type = content_type
		crate.set_network_master(player_network_unique_id)
		add_child(crate)
		crate.lauching_at(Vector3.ZERO, 0.0)
		crate.connect("on_pickup", self, "_on_supply_crate_picked_up")
		
		add_minimap_object(crate.get_path())
	
func _on_supply_crate_picked_up(_node, _by):
	if not get_tree().is_network_server():
		return
		
	var message = ""
	if _node.content_type == FlyingCrate.CONTENT_TYPE_AMMO:
		var slot = rand_range(0, _by.weapons.size())
		var ammo = int(rand_range(1, _by.weapons[slot].max_ammo))
		message = "+" + str(ammo) + " " + _by.weapons[slot].name
		_by.restock_ammo(slot,ammo)
		
	elif _node.content_type == FlyingCrate.CONTENT_TYPE_HP:
		var hp = round(rand_range(10, _by.max_hp))
		message = "+" + str(hp) + " HP"
		_by.restore_hp(hp)
		
	elif _node.content_type == FlyingCrate.CONTENT_TYPE_CASH:
		var cash = round(rand_range(_min_cash, _max_cash))
		message = "$"+str(cash)+" Cash"
		rpc("_cash_pickup", _by.owner_id, cash)
		cash_obtain(cash)
		
	rpc("_spawn_floating_message",message, _node.translation)
	
remotesync func _cash_pickup(_player_id, _amount):
	if Global.player_data.id == _player_id:
		Global.player_data.cash += _amount
		cash_obtain(_amount)
		
func cash_obtain(_amount):
	pass
	
remotesync func _spawn_floating_message(message : String, translation : Vector3, color : Color = Color.white):
	var msg = preload("res://assets/ui/message-3d/message_3d.tscn").instance()
	add_child(msg)
	msg.set_color(color)
	msg.translation = translation
	# msg.translation.y = Ship.DEFAULT_ALTITUDE
	msg.set_message(message)
	
################################################################
# player and bot signal handle event
func _on_enemy_click(_node):
	if not _node.has_method("take_damage"):
		return
		
	_on_body_enter_aim_sight(_node)
	
func _on_enemy_on_spawning_weapon(_node):
	if not _node.has_method("take_damage"):
		return
		
	add_minimap_object(_node.get_path())
	_node.connect("on_click", self ,"_on_enemy_click")
	
func _on_enemy_fort_on_destroyed(_node):
	_on_enemy_on_destroyed(_node)
	
func _on_enemy_ship_on_destroyed(_node):
	_on_enemy_on_destroyed(_node)
	
func _on_enemy_on_destroyed(_node):
	if get_tree().is_network_server():
		rpc("_despawn_hostile_airship", _node.get_path())
	
func _on_airship_on_spawning_weapon(_node):
	if _node.side == HOSTILE_SIDE:
		return
		
	if not _node.has_method("take_damage"):
		return
		
	add_minimap_object(_node.get_path())
	_airborne_targets.append(_node)
		
func _on_player_on_falling(_node):
	if get_tree().is_network_server():
		_airborne_targets.erase(_node)
	
func _on_player_on_destroyed(_node):
	remove_minimap_object(_node.get_path())
	
################################################################
# player aim system
func _on_camera_moving(_translation, _zoom):
	_aim_point = _translation
	
func _on_body_enter_aim_sight(_body):
	if not is_instance_valid(_player):
		return
		
	if _player.destroyed:
		return
		
	if _body == _player:
		return
		
	if _body.owner_id == _player.owner_id or _body.side == _player.side:
		return
		
	if is_instance_valid(_lock_on_point):
		_lock_on_point.highlight(false)
		
	_lock_on_point = _body
	_lock_on_point.highlight(true)
	
################################################################
# bot command to where move and what to shot
# this funnction only run in host player
func give_command_to_move_to_airship_bot(holder_path : NodePath, terrain_path : NodePath):
	var holder = get_node_or_null(holder_path)
	if not is_instance_valid(holder):
		return
		
	var terrain = get_node_or_null(terrain_path)
	if not is_instance_valid(terrain):
		return
		
	if terrain.feature_translations.empty():
		return
		
	var pos = terrain.feature_translations[randi() % terrain.feature_translations.size()]
	
	var bots = holder.get_children()
	if bots.empty():
		return
		
	var bot = bots[randi() % bots.size()]
	if not is_instance_valid(bot):
		return
		
	bot.waypoint = pos
		
	
func give_command_to_shot_to_airship_bot(holder_path : NodePath):
	var holder = get_node_or_null(holder_path)
	if not is_instance_valid(holder):
		return
		
	var bots = holder.get_children()
	if bots.empty():
		return
		
	var bot = bots[randi() % bots.size()]
	if not is_instance_valid(bot):
		return
		
	var targets = _airborne_targets.duplicate()
	if targets.empty():
		return
		
	targets.erase(bot)
		
	erase_empty(targets)
	if targets.empty():
		return
		
	var target = targets[randi() % targets.size()]
	if randf() < _aggresion:
		bot.shot(
			rand_range(0, bot.weapons.size()),
			target.translation,
			target.get_path(),
			target.get_path()
		)
	
# erase invalid instance
# in array
func erase_empty(arr):
	var erase_target = []
	for i in arr:
		if not is_instance_valid(i):
			erase_target.append(i)
		
	for i in erase_target:
		arr.erase(i)
		
################################################################
# player network tick for sync targeting system
func sync_targeting_system():
	if not is_instance_valid(_player_aim_guider):
		return
		
	if not is_instance_valid(_player):
		return
		
	if _aim_point:
		rpc_unreliable("_aim",_player.get_path(), _aim_point)
		rpc_unreliable("_guide_aim", _player_aim_guider.get_path(), _aim_point)
		
	if is_instance_valid(_lock_on_point):
		rpc_unreliable("_lock_on",_player.get_path(),_lock_on_point.get_path())
	
################################################################














