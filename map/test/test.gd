extends Node

var HOSTILE_SHIPS = {
	"res://scene/ships/cruiser/cruiser.tscn" : Ship.SHIP_LIST[2],
	"res://scene/ships/carrier/carrier.tscn" : Ship.SHIP_LIST[0],
	"res://scene/ships/bomber/bomber.tscn" : Ship.SHIP_LIST[1],
}
var HOSTILE_INSTALATION = {
	"res://scene/fort/aa-instalation/aa_instalation.tscn" : Weapon.AA_FORT_TEMPLATE,
	"res://scene/fort/airstrip/airstrip.tscn" : Weapon.CARRIER_TEMPLATES
}

signal player_on_ready(player)

const MAX_HOSTILE = 4
const MAX_INSTALATION = 3

var airborne_targets = []

onready var _player = null
onready var _terrain = $terrain
onready var _camera = $cameraPivot
onready var _cursor = $cursor
onready var _ui = $ui

var is_aiming = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_player= load(Global.selected_ship.scene).instance()
	_player.owner_id = str(GDUUID.v4())
	_player.side = "player"
	_player.MINIMAP_COLOR = Color.green

	_player.set_data(Global.selected_ship)
	add_child(_player)
	
	_player.connect("on_destroyed",_ui,"_on_player_on_destroyed")
	_player.connect("on_falling",self,"_on_player_on_falling")
	_player.connect("on_falling",_ui,"_on_player_on_falling")
	_player.connect("on_move",self,"_on_player_on_move")
	_player.connect("on_spawning_weapon" ,self,"_on_player_on_spawning_weapon")
	_player.connect("on_take_damage",_ui,"_on_player_on_take_damage")
	
	_player.translation = Vector3(0, 10, 0)
	_player.show_hp_bar(false)
	_player.set_hp_bar_color(Color.green)
	_player.make_ready()
	
	emit_signal("player_on_ready", _player)
	
	airborne_targets.append(_player)
	
	_ui.add_minimap_object(_player)
	_ui.set_camera(_camera)
	
	_terrain.generate()
	_on_enemy_decision_timer_timeout()
		
	_terrain.unused_translations.shuffle()
	for _pos in _terrain.unused_translations:
		var forts_count = $instalation_holder.get_child_count()
		if forts_count >= MAX_INSTALATION:
			return
			
		spawn_hostile_fort(_pos.node_translation)
	
# spawn instalation fort
func spawn_hostile_fort(_pos):
	var fort_data = HOSTILE_INSTALATION.keys()[randi() % HOSTILE_INSTALATION.keys().size()]
	var fort = load(fort_data).instance()
	var color = Color.orange #Color(randf(),randf(),randf(), 1)
	
	$instalation_holder.add_child(fort)
	fort.translation = _pos
	fort.translation.y = 1.0
	
	fort.weapons.clear()
	for i in HOSTILE_INSTALATION[fort_data]:
		fort.weapons.append(i.duplicate())
	
	fort.MINIMAP_COLOR = color
	fort.owner_id = str(GDUUID.v4())
	fort.side = str(GDUUID.v4()) + "-side"
	fort.hp = 500.0
	fort.max_hp = 500.0
	fort.show_hp_bar(true)
	fort.set_hp_bar_color(color)
	fort.connect("on_destroyed", self, "_on_enemy_on_destroyed")
	fort.connect("on_spawning_weapon", self, "_on_player_on_spawning_weapon")
	_ui.add_minimap_object(fort)
	
	
# spawn airship
func spawn_hostile_airship():
	var bots_count = $bot_holder.get_child_count()
	if bots_count >= MAX_HOSTILE:
		return
		
	if _terrain.cloud_spawn_points.empty():
		return
		
	var spawn_pos = _terrain.cloud_spawn_points[randi() % _terrain.cloud_spawn_points.size()]
	
	var ship_data_key = HOSTILE_SHIPS.keys()[randi() % HOSTILE_SHIPS.keys().size()]
	var ship = load(ship_data_key).instance()
	var color = Color.red #Color(randf(),randf(),randf(), 1)
	
	$bot_holder.add_child(ship)
	ship.translation = spawn_pos
	ship.translation.y = Ship.DEFAULT_ALTITUDE
	ship.MINIMAP_COLOR = color
	ship.owner_id = str(GDUUID.v4())
	ship.side = str(GDUUID.v4()) + "-side"
	ship.set_data(HOSTILE_SHIPS[ship_data_key])
	ship.show_hp_bar(true)
	ship.set_hp_bar_color(color)
	ship.connect("on_destroyed", self, "_on_enemy_on_destroyed")
	ship.connect("on_spawning_weapon", self, "_on_player_on_spawning_weapon")
	_ui.add_minimap_object(ship)
	
	airborne_targets.append(ship)
	
# test clicking ground
func _on_terrain_on_ground_clicked(_translation):
	_player.waypoint= _translation
	_cursor.translation = _translation
	_cursor.show()
	
	
	
# testing UI
func _on_ui_on_aim_press(_is_press):
	_camera.aim_reticle(_is_press)
	is_aiming = _is_press
	
	if is_instance_valid(_player.lock_on_point):
		_player.lock_on_point.highlight(is_aiming)
		
func _on_ui_on_shot_press(_index):
	if _player.has_method("shot"):
		_player.shot(_index)
	
	
	
	
	
	
# testing bots
func _on_enemy_decision_timer_timeout():
	fort_bot()
	airborne_bot()
	
func airborne_bot():
	var bots = $bot_holder.get_children()
	if bots.empty():
		return
		
	var targets = airborne_targets.duplicate()
	if targets.empty():
		return
	
	var bot = bots[randi() % bots.size()]
	targets.erase(bot)
	
	if _terrain.feature_translations.empty():
		return
	
	var pos = _terrain.feature_translations[randi() % _terrain.feature_translations.size()]
	bot.waypoint= pos
	
	var target = targets[randi() % targets.size()]
	while not is_instance_valid(target):
		target = targets[randi() % targets.size()]
		
	if randf() < 0.8:
		bot.aim_point = target.translation
		bot.guided_point = target
		bot.lock_on_point = target
		bot.shot(rand_range(0,bot.weapons.size()))
		
	
	
	
	
func fort_bot():
	var forts = $instalation_holder.get_children()
	if forts.empty():
		return
		
	if  airborne_targets.empty():
		return
		
	var target = airborne_targets[randi() % airborne_targets.size()]
	while not is_instance_valid(target):
		target = airborne_targets[randi() % airborne_targets.size()]
		
	var fort = forts[randi() % forts.size()]
	
	fort.aim_point = target.translation
	fort.guided_point = target
	fort.lock_on_point = target
	fort.shot(rand_range(0,fort.weapons.size()))
	
	
func _on_enemy_spawning_timer_timeout():
	spawn_hostile_airship()
	
func _on_player_on_spawning_weapon(_node):
	if _node.has_method("take_damage"):
		airborne_targets.append(_node)
	_ui.add_minimap_object(_node)
	
	
func _on_enemy_on_destroyed(_node):
	airborne_targets.erase(_node)
	_ui.remove_minimap_object(_node)
	_node.queue_free()
	
	
	
	
	
	
# testing player
func _on_player_on_move(_node, _translation):
	$marker.translation = _translation
	$marker.translation.y = 8.0
	if not is_aiming:
		_camera.translation = _translation
		
func _on_player_on_falling(_node):
	if is_instance_valid(_player.lock_on_point):
		_player.lock_on_point.highlight(false)
		
	_camera.translation =_node.translation
	
	
	
	
# camera and amining tes
func _on_cameraPivot_on_body_enter_aim_sight(body):
	if not is_aiming:
		return
		
	if not body is KinematicBody:
		return
		
	if body == _player:
		return
		
	if body.owner_id == _player.owner_id:
		return
	
	if is_instance_valid(_player.lock_on_point):
		_player.lock_on_point.highlight(false)
		
	_player.lock_on_point = body
	_player.lock_on_point.highlight(true)
	
func _on_cameraPivot_on_camera_moving(_translation, _zoom):
	_player.aim_point = _translation
	_player.guided_point = _camera
	
	
# respawn
func _on_ui_on_respawn_click():
	var pos = _terrain.feature_translations[randi() % _terrain.feature_translations.size()]
	_player.destroyed = false
	_player.hp = _player.max_hp
	
	_player.weapons.clear()
	for i in Weapon.CARRIER_TEMPLATES:
		_player.weapons.append(i.duplicate())
		
	_player.translation = pos
	_player.translation.y = Ship.DEFAULT_ALTITUDE
	_player.make_ready()
	
