extends MP_Battle

onready var _bot_holder = $bot_airship_holder

onready var _camera = $cameraPivot
onready var _terrain = $terrain
onready var _cursor = $cursor
onready var _network_tick = $network_tick
onready var _ui = $ui

onready var _targeting_guide_holder = $targeting_guide_holder
onready var _player_holder = $player_holder

var team = "player"

var _player_1 : KinematicBody = null
var _player_1_aim : Spatial = null

# Called when the node enters the scene tree for the first time.
func _ready():
	init_host()
	
	var spawn_pos = Vector3(0, 10, 0)
	for i in Global.mp_battle_data:
		var spatial_target = Spatial.new()
		_targeting_guide_holder.add_child(spatial_target)
		spatial_target.name = "PLAYER-TARGET-" + i.owner_id
		spatial_target.translation = spawn_pos
		
		var ship = load(i.scene).instance()
		_player_holder.add_child(ship)
		ship.owner_id = i.owner_id
		ship.side = team
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
		
		if ship.owner_id == Global.player_data.id:
			_player_1 = ship
			_player_1_aim = spatial_target
			ship.MINIMAP_COLOR = Color.green
		
		
		_airborne_targets.append(ship)
		_ui.add_minimap_object(ship)
		spawn_pos.x += 5.0
		
			
	_player_1.show_hp_bar(false)
	_player_1.set_hp_bar_color(Color.green)
	_player_1.set_hp_bar_name(Global.player_data.name)
	
	_player_1.connect("on_move", self, "_on_player_on_move")
	_player_1.connect("on_destroyed",_ui,"_on_player_on_destroyed")
	_player_1.connect("on_falling",self,"_on_player_on_falling")
	_player_1.connect("on_falling",_ui,"_on_player_on_falling")
	_player_1.connect("on_spawning_weapon" ,self,"_on_airship_on_spawning_weapon")
	_player_1.connect("on_take_damage",_ui,"_on_player_on_take_damage")
	
	_ui.set_camera(_camera)
	
	emit_signal("player_on_ready", _player_1)
	
	_network_tick.start()
	_terrain.generate()
	
################################################################
# network connection
func init_host():
	Network.connect("server_disconnected", self , "_server_disconnected")
	Network.connect("connection_closed", self , "_connection_closed")
	
func _connection_closed():
	_server_disconnected()
	
func _server_disconnected():
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
################################################################
# server grpc functions
remote func _request_terrain_data(from_id : int):
	if not get_tree().is_network_server():
		return
		
	rpc_id(from_id,"_receive_terrain_data",
		_terrain.unused_translations,
		_terrain.feature_translations,
		_terrain.features,
		_terrain.season
	)
	
################################################################
# server player movement
# and aim system
func _on_terrain_on_ground_clicked(_translation):
	if not is_instance_valid(_player_1):
		return
		
	if _spectate_mode:
		return
		
	_cursor.translation = _translation
	_cursor.show()
	_move(_player_1.get_path(), _translation)
	
func _on_player_on_move(_node, _translation):
	if not _aim_mode or _spectate_mode:
		_camera.translation = _translation
	
func _on_cameraPivot_on_camera_moving(_translation, _zoom):
	_aim_point = _translation
	
func _on_cameraPivot_on_body_enter_aim_sight(_body):
	if not is_instance_valid(_player_1):
		return
		
	if _player_1.destroyed:
		return
		
	if _body == _player_1:
		return
		
	if _body.owner_id == _player_1.owner_id or _body.side == _player_1.side:
		return
		
	_lock_on_point = _body
	_body.highlight(true)
	
################################################################
# network tick to send automatic request
func _on_network_tick_timeout():
	if not is_instance_valid(_player_1_aim):
		return
		
	if not is_instance_valid(_player_1):
		return
		
	if _aim_point:
		rpc_unreliable("_aim",_player_1.get_path(), _aim_point)
		rpc_unreliable("_guide_aim", _player_1_aim.get_path(), _aim_point)
	
	if is_instance_valid(_lock_on_point):
		rpc_unreliable("_lock_on",_player_1.get_path(),_lock_on_point.get_path())
	
################################################################
# on ui action
func _on_ui_on_aim_mode(_val):
	_aim_mode = _val
	_camera.aim_reticle(_aim_mode)
	
func _on_ui_on_shot_press(_index):
	if not is_instance_valid(_player_1):
		return
		
	if _player_1.has_method("shot"):
		_player_1.shot(_index)
		
func _on_ui_on_next_click():
	_spectate_mode = true
	for p in _player_holder.get_children():
		for _signal in p.get_signal_connection_list("on_move"):
			p.disconnect("on_move", self, _signal.method)
			
	if _spectate_cicle_pos > _player_holder.get_child_count():
		_spectate_cicle_pos = 0
		
	var p = _player_holder.get_children()[_spectate_cicle_pos]
	p.connect("on_move", self, "_on_player_on_move")
		
	_spectate_cicle_pos += 1
	
func _on_ui_on_exit_click():
	_network_tick.stop()
	Network.disconnect_from_server()
	
################################################################
# player signal handle event
func _on_player_on_falling(_node):
	if is_instance_valid(_player_1.lock_on_point):
		_player_1.lock_on_point.highlight(false)
		
	_camera.translation = _node.translation
	_airborne_targets.erase(_node)
	
################################################################
# event countdown on host player
# spawning hostile bot
func _on_event_timer_timeout():
	if not get_tree().network_peer:
		return
		
	if _terrain.cloud_spawn_points.empty():
		return
		
	var ship_name =  "BOT-" + str(GDUUID.v4())
	var spawn_pos = _terrain.cloud_spawn_points[randi() % _terrain.cloud_spawn_points.size()]
	var ship_data_key = HOSTILE_SHIPS.keys()[randi() % HOSTILE_SHIPS.keys().size()]
	
	rpc("_spawn_hostile_airship", Network.PLAYER_HOST_ID, ship_name, ship_data_key, _bot_holder.get_path(),_ui.get_path(), spawn_pos)
	
################################################################
# timeout to bot command to where move and what to shot
func _on_bot_command_timer_timeout():
	give_command_to_airship_bot(_bot_holder.get_path(), _terrain.get_path())
	
	
	
	
	
	
	






