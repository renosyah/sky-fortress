extends Node
class_name MP_Battle

const MAX_HOSTILE = 1
const HOSTILE_SIDE = "BOT"
const PLAYER_SIDE = "player"

var HOSTILE_SHIPS = {
	"res://scene/ships/cruiser/cruiser.tscn" : Ships.SHIP_LIST[2],
	"res://scene/ships/carrier/carrier.tscn" : Ships.SHIP_LIST[0],
	"res://scene/ships/bomber/bomber.tscn" : Ships.SHIP_LIST[1],
}
var HOSTILE_INSTALATION = {
	"res://scene/fort/aa-instalation/aa_instalation.tscn" : Forts.FORT_LIST[0],
	"res://scene/fort/airstrip/airstrip.tscn" : Forts.FORT_LIST[1]
}
var _aggresion = 0.8

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


################################################################
# network connection watcher
# for both client and host
func init_connection_watcher():
	Network.connect("server_disconnected", self , "_server_disconnected")
	Network.connect("connection_closed", self , "_connection_closed")
	
func _connection_closed():
	_server_disconnected()
	
func _server_disconnected():
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
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
		
		if ship.owner_id == Global.player_data.id:
			_player = ship
			_player_aim_guider = spatial_target
			ship.MINIMAP_COLOR = Color.green
			
		_ui.add_minimap_object(ship)
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
remotesync func _spawn_hostile_airship(player_network_unique_id:int, name:String, ship_data_key:String, holder_path:NodePath, ui_path:NodePath, _spawn_pos:Vector3):
	var holder = get_node_or_null(holder_path)
	if not is_instance_valid(holder):
		return
		
	var ui = get_node_or_null(ui_path)
	if not is_instance_valid(ui):
		return
		
	var bots_count = holder.get_child_count()
	if bots_count >= MAX_HOSTILE:
		return
		
	var ship = load(ship_data_key).instance()
	var color = Color.red
	
	ship.owner_id = HOSTILE_SIDE
	ship.side = HOSTILE_SIDE
	ship.name = name
	ship.set_data(HOSTILE_SHIPS[ship_data_key])
	ship.set_network_master(player_network_unique_id)
	ship.MINIMAP_COLOR = color
	holder.add_child(ship)
	
	ship.translation = _spawn_pos
	ship.translation.y = Ship.DEFAULT_ALTITUDE
	ship.show_hp_bar(true)
	ship.set_hp_bar_color(color)
	ship.connect("on_click", self ,"_on_enemy_click")
	ship.connect("on_spawning_weapon", self, "_on_enemy_on_spawning_weapon")
	ship.connect("on_destroyed", self, "_on_enemy_on_destroyed")
	
	ui.add_minimap_object(ship)
	
remotesync func _spawn_hostile_fort(player_network_unique_id:int, name:String, fort_data_key:String, holder_path:NodePath, ui_path:NodePath, _spawn_pos:Vector3):
	var holder = get_node_or_null(holder_path)
	if not is_instance_valid(holder):
		return
		
	var ui = get_node_or_null(ui_path)
	if not is_instance_valid(ui):
		return
		
	var bots_count = holder.get_child_count()
	if bots_count >= MAX_HOSTILE:
		return
		
	var fort = load(fort_data_key).instance()
	var color = Color.red #Color(randf(),randf(),randf(), 1)
	
	fort.owner_id = HOSTILE_SIDE
	fort.side = HOSTILE_SIDE
	fort.name = name
	fort.set_data(HOSTILE_INSTALATION[fort_data_key])
	fort.set_network_master(player_network_unique_id)
	fort.MINIMAP_COLOR = color
	fort.targets = _airborne_targets
	holder.add_child(fort)
	
	fort.translation = _spawn_pos
	fort.translation.y = 1.0
	fort.show_hp_bar(true)
	fort.set_hp_bar_color(color)
	fort.connect("on_click", self ,"_on_enemy_click")
	fort.connect("on_spawning_weapon", self, "_on_enemy_on_spawning_weapon")
	fort.connect("on_destroyed", self, "_on_enemy_on_destroyed")
	
	ui.add_minimap_object(fort)
	
remotesync func _despawn_hostile_airship(node_path : NodePath):
	var _node = get_node_or_null(node_path)
	if not is_instance_valid(_node):
		return
		
	_node.queue_free()
	
################################################################
# player and bot signal handle event
func _on_enemy_click(_node):
	if not _node.has_method("take_damage"):
		return
		
	_on_body_enter_aim_sight(_node)
	
func _on_enemy_on_spawning_weapon(_node):
	if not _node.has_method("take_damage"):
		return
		
	_node.connect("on_click", self ,"_on_enemy_click")
	
func _on_enemy_on_destroyed(_node):
	if get_tree().is_network_server():
		rpc("_despawn_hostile_airship", _node.get_path())
	
func _on_airship_on_spawning_weapon(_node):
	if _node.side == HOSTILE_SIDE:
		return
		
	if _node.has_method("take_damage"):
		_airborne_targets.append(_node)
	
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














