extends MP_Battle

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
	rpc_id(Network.PLAYER_HOST_ID,"_request_terrain_data", Global.client.network_unique_id)
	
	emit_signal("player_on_ready", _player)
	
################################################################
# client grpc functions
remote func _receive_terrain_data(unused_translations :Array,feature_translations :Array,features :Array,season : String):
	if get_tree().is_network_server():
		return
		
	_terrain.unused_translations = unused_translations
	_terrain.feature_translations = feature_translations
	_terrain.features = features
	_terrain.season = season
	
	_terrain.generate()
	
################################################################
# client player movement
# and aim system
func _on_terrain_on_ground_clicked(_translation):
	if not is_instance_valid(_player):
		return
		
	if _spectate_mode:
		return
		
	_cursor.translation = _translation
	_cursor.show()
	rpc_id(Network.PLAYER_HOST_ID,"_move", _player.get_path(),_translation)
	
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
	._on_player_on_falling(_node)
	
	if is_instance_valid(_player.lock_on_point):
		_player.lock_on_point.highlight(false)
		
	_camera.translation = _node.translation
	_spectate_mode = true
	
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
		
	var cicle_size = _alive_players.size() - 1
	if _is_next:
		_spectate_cicle_pos += 1
		if _spectate_cicle_pos > cicle_size:
			_spectate_cicle_pos = 0
	else:
		_spectate_cicle_pos -= 1
		if _spectate_cicle_pos < 0:
			_spectate_cicle_pos = cicle_size
		
	var p = _alive_players[_spectate_cicle_pos]

	p.connect("on_move", self, "_on_player_on_move")
	
	_camera.translation = p.translation
	_ui.set_spectating_name(p.owner_name)
	
################################################################








