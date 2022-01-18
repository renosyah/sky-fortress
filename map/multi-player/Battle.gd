extends Node
class_name MP_Battle

const team = "player"
const MAX_HOSTILE = 1
const HOSTILE_SIDE = "BOT"
var HOSTILE_SHIPS = {
	"res://scene/ships/cruiser/cruiser.tscn" : Ship.SHIP_LIST[2],
	"res://scene/ships/carrier/carrier.tscn" : Ship.SHIP_LIST[0],
	"res://scene/ships/bomber/bomber.tscn" : Ship.SHIP_LIST[1],
}

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
# hostile airship manager
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
	ship.connect("on_destroyed", self, "_on_enemy_on_destroyed")
	
	ui.add_minimap_object(ship)
	
remotesync func _despawn_hostile_airship(node_path : NodePath):
	var _node = get_node_or_null(node_path)
	if not is_instance_valid(_node):
		return
		
	_airborne_targets.erase(_node)
	_node.queue_free()
	
################################################################
# player and bot signal handle event
func _on_enemy_on_destroyed(_node):
	rpc("_despawn_hostile_airship", _node.get_path())
	
	
func _on_airship_on_spawning_weapon(_node):
	if _node.has_method("take_damage"):
		_airborne_targets.append(_node)
		
################################################################
# bot command to where move and what to shot
# this funnction only run in host player
func give_command_to_airship_bot(holder_path : NodePath, terrain_path : NodePath):
	var holder = get_node_or_null(holder_path)
	if not is_instance_valid(holder):
		return
		
	var terrain = get_node_or_null(terrain_path)
	if not is_instance_valid(terrain):
		return
		
	var bots = holder.get_children()
	if bots.empty():
		return
		
	var targets = _airborne_targets.duplicate()
	if targets.empty():
		return
		
	var erase_target = []
	for i in targets:
		if not is_instance_valid(i):
			erase_target.append(i)
	
	for i in erase_target:
		targets.erase(i)
		
	if targets.empty():
		return
		
	var bot = bots[randi() % bots.size()]
	targets.erase(bot)
	
	if terrain.feature_translations.empty():
		return
	
	var pos = terrain.feature_translations[randi() % terrain.feature_translations.size()]
	bot.waypoint = pos
	
	var target = targets[randi() % targets.size()]
	if randf() < 0.8:
		bot.shot(
			rand_range(0, bot.weapons.size()),
			target.translation,
			target.get_path(),
			target.get_path()
		)






















