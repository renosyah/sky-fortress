extends Node

const HOSTILE_SHIPS = [
	preload("res://scene/ships/cruiser/cruiser.tscn"),
	preload("res://scene/ships/carrier/carrier.tscn")
]
const MAX_HOSTILE = 5

onready var _terrain = $terrain
onready var _camera = $cameraPivot
onready var _cursor = $cursor
onready var _ui = $ui

var is_aiming = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$player.owner_id = str(GDUUID.v4())
	$player.side = "player"
	$player.MINIMAP_COLOR = Color.green
	$player.show_hp_bar(false)
	$player.set_hp_bar_color(Color.green)
	$player.weapons.clear()
	for i in Weapon.TEMPLATES:
		$player.weapons.append(i.duplicate())
	$player.make_ready()
	
	_ui.add_minimap_object($player)
	_ui.set_camera(_camera)
	_terrain.generate()
	_on_enemy_decision_timer_timeout()
	
	
	
# test clicking ground
func _on_terrain_on_ground_clicked(_translation):
	$player.waypoint= _translation
	_cursor.translation = _translation
	_cursor.show()
	
	
	
# testing UI
func _on_ui_on_aim_press(_is_press):
	_camera.aim_reticle(_is_press)
	is_aiming = _is_press
	
func _on_ui_on_shot_press(_index):
	if $player.has_method("shot"):
		$player.aim_point = _camera.translation
		$player.guided_point = _camera
		$player.shot(_index)
	
	
	
# testing bots
func _on_enemy_decision_timer_timeout():
	var bots = $bot_holder.get_children()
	
	if bots.empty():
		return
	
	var bot = bots[randi() % bots.size()]
	
	var targets = bots.duplicate()
	targets.append($player)
	targets.erase(bot)
	
	if _terrain.feature_translations.empty():
		return
	
	var pos = _terrain.feature_translations[randi() % _terrain.feature_translations.size()]
	bot.waypoint= pos
	
	var target = targets[randi() % targets.size()]
	
	if randf() < 0.8 and targets.size() >= 5:
		bot.aim_point = target.translation
		bot.guided_point = target
		bot.lock_on_point = target
		bot.shot(rand_range(0,bot.weapons.size()))
		
	
func _on_enemy_spawning_timer_timeout():
	var bots_count = $bot_holder.get_child_count()
	if bots_count >= MAX_HOSTILE:
		return
		
	if _terrain.cloud_spawn_points.empty():
		return
		
	var spawn_pos = _terrain.cloud_spawn_points[randi() % _terrain.cloud_spawn_points.size()]
	
	var ship = HOSTILE_SHIPS[randi() % HOSTILE_SHIPS.size()].instance()
	$bot_holder.add_child(ship)
	ship.translation = spawn_pos
	ship.translation.y = Ship.DEFAULT_ALTITUDE
	ship.weapons.clear()
	for i in Weapon.TEMPLATES:
		ship.weapons.append(i.duplicate())
	ship.MINIMAP_COLOR = Color.red
	ship.owner_id = str(GDUUID.v4())
	ship.side = str(GDUUID.v4()) + "-side"
	ship.show_hp_bar(true)
	ship.set_hp_bar_color(Color.red)
	ship.connect("on_destroyed", self, "_on_enemy_on_destroyed")
	ship.connect("on_spawning_weapon", self, "_on_player_on_spawning_weapon")
	_ui.add_minimap_object(ship)
	
func _on_enemy_on_destroyed(_node):
	_ui.remove_minimap_object(_node)
	_node.queue_free()
	
	
	
	
# testing player
func _on_player_on_move(_node, _translation):
	if not is_aiming:
		_camera.translation = _translation
	
# camera and amining tes
func _on_cameraPivot_on_body_enter_aim_sight(body):
	if not body is KinematicBody:
		return
		
	if body == $player:
		return
		
	if body.owner_id == $player.owner_id:
		return
	
	$player.lock_on_point = body
	
	
# respawn
func _on_ui_on_respawn_click():
	var pos = _terrain.feature_translations[randi() % _terrain.feature_translations.size()]
	$player.destroyed = false
	$player.hp = $player.max_hp
	$player.weapons.clear()
	for i in Weapon.TEMPLATES:
		$player.weapons.append(i.duplicate())
	$player.translation = pos
	$player.translation.y = Ship.DEFAULT_ALTITUDE
	$player.make_ready()
	
func _on_player_on_spawning_weapon(_node):
	_ui.add_minimap_object(_node)
