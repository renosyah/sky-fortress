extends MP_Battle

onready var _bot_holder = $bot_airship_holder
onready var _fort_holder = $bot_fort_holder

onready var _camera = $cameraPivot
onready var _terrain = $terrain
onready var _cursor = $cursor
onready var _network_tick = $network_tick
onready var _ui = $ui

onready var _targeting_guide_holder = $targeting_guide_holder
onready var _player_holder = $player_holder

# Called when the node enters the scene tree for the first time.
func _ready():
	.init_connection_watcher()
	.spawn_players(_player_holder.get_path(), _targeting_guide_holder.get_path(), _ui.get_path())
	
	_ui.set_camera(_camera)
	_network_tick.start()
	_terrain.generate()
	
	emit_signal("player_on_ready", _player)
	
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
# player movement and aim system
func _on_terrain_on_ground_clicked(_translation):
	if not is_instance_valid(_player):
		return
		
	if _spectate_mode:
		return
		
	_cursor.translation = _translation
	_cursor.show()
	_move(_player.get_path(), _translation)
	
func _on_player_on_move(_node, _translation):
	if not _aim_mode or _spectate_mode:
		_camera.translation = _translation
	
func _on_cameraPivot_on_camera_moving(_translation, _zoom):
	._on_camera_moving(_translation, _zoom)
	
func _on_cameraPivot_on_body_enter_aim_sight(_body):
	._on_body_enter_aim_sight(_body)
	
################################################################
# network tick to send automatic request
func _on_network_tick_timeout():
	.sync_targeting_system()
	
################################################################
# on ui action
func _on_ui_on_aim_mode(_val):
	_aim_mode = _val
	_camera.aim_reticle(_aim_mode)
	
func _on_ui_on_shot_press(_index):
	if not is_instance_valid(_player):
		return
		
	if _player.has_method("shot"):
		_player.shot(_index)
		
func _on_ui_on_next_click():
	spectate_cycle(true)
	
func _on_ui_on_prev_click():
	spectate_cycle(false)
	
func _on_ui_on_exit_click():
	_network_tick.stop()
	Network.disconnect_from_server()
	
################################################################
# player signal handle event
func _on_player_on_falling(_node):
	if is_instance_valid(_player.lock_on_point):
		_player.lock_on_point.highlight(false)
		
	_camera.translation = _node.translation
	_spectate_mode = true
	_airborne_targets.erase(_node)
	
################################################################
# spectate cicle
func spectate_cycle(_is_next : bool):
	_spectate_mode = true
		
	var _alive_players = []
	for i in _player_holder.get_children():
		if not i.destroyed:
			_alive_players.append(i)
		
	if _alive_players.empty():
		return
		
	for p in _player_holder.get_children():
		for _signal in p.get_signal_connection_list("on_move"):
			p.disconnect("on_move", self, _signal.method)
		
	_spectate_cicle_pos += (1 if _is_next else -1)
	var cicle_size = _alive_players.size()
	if _spectate_cicle_pos >=  cicle_size or _spectate_cicle_pos < cicle_size:
		_spectate_cicle_pos = 0
		
	var p = _alive_players[_spectate_cicle_pos]
	p.connect("on_move", self, "_on_player_on_move")
	
	_camera.translation = p.translation
	
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
	
	var fort_name =  "FORT-BOT-" + str(GDUUID.v4())
	var spawn_pos_fort = _terrain.unused_translations[randi() % _terrain.unused_translations.size()]
	var fort_data_key = HOSTILE_INSTALATION.keys()[randi() % HOSTILE_INSTALATION.keys().size()]
	
	rpc("_spawn_hostile_airship", Network.PLAYER_HOST_ID, ship_name, ship_data_key, _bot_holder.get_path(),_ui.get_path(), spawn_pos)
	
	rpc("_spawn_hostile_fort", Network.PLAYER_HOST_ID, fort_name, fort_data_key, _fort_holder.get_path(),_ui.get_path(), spawn_pos_fort.node_translation)
	
################################################################
# timeout to bot command to where move and what to shot
func _on_bot_command_timer_timeout():
	give_command_to_move_to_airship_bot(_bot_holder.get_path(), _terrain.get_path())

func _on_bot_shotting_timer_timeout():
	give_command_to_shot_to_airship_bot(_bot_holder.get_path())







