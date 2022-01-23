extends MP_Battle

onready var _bot_holder = $bot_airship_holder

onready var _camera = $cameraPivot
onready var _terrain = $terrain
onready var _cursor = $cursor
onready var _network_tick = $network_tick
onready var _ui = $ui

onready var _targeting_guide_holder = $targeting_guide_holder
onready var _player_holder = $player_holder

# Called when the node enters the scene tree for the first time.
func _ready():
	init_connection_watcher()
		
	var spawn_pos = Vector3(0, 10, 0)
	for i in Global.mp_players_data:
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
		ship.update_hp_bar()
		
		if i.owner_id == Global.player_data.id:
			_player = ship
			_player_aim_guider = spatial_target
			ship.MINIMAP_COLOR = Color.green
			
		_ui.add_minimap_object(ship)
		spawn_pos.x += 5.0
		
			
	_player.show_hp_bar(false)
	_player.set_hp_bar_color(Color.green)
	
	_player.connect("on_move", self, "_on_player_on_move")
	_player.connect("on_destroyed",_ui,"_on_player_on_destroyed")
	_player.connect("on_falling",self,"_on_player_on_falling")
	_player.connect("on_falling",_ui,"_on_player_on_falling")
	_player.connect("on_spawning_weapon" ,self,"_on_airship_on_spawning_weapon")
	_player.connect("on_take_damage",_ui,"_on_player_on_take_damage")
	
	_ui.set_camera(_camera)
	
	emit_signal("player_on_ready", _player)
	
	_network_tick.start()
	rpc_id(Network.PLAYER_HOST_ID,"_request_terrain_data", Global.client.network_unique_id)
	
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
	_aim_point = _translation
	
func _on_cameraPivot_on_body_enter_aim_sight(_body):
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
# network tick to send automatic request
func _on_network_tick_timeout():
	if not is_instance_valid(_player_aim_guider):
		return
		
	if not is_instance_valid(_player):
		return
		
	if _aim_point:
		rpc_unreliable("_aim",_player.get_path(), _aim_point)
		rpc_unreliable("_guide_aim", _player_aim_guider.get_path(), _aim_point)
	
	if is_instance_valid(_lock_on_point):
		rpc_unreliable("_lock_on",_player.get_path(), _lock_on_point.get_path())
	
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
		
	_spectate_cicle_pos += 1
	if _spectate_cicle_pos >= _alive_players.size():
		_spectate_cicle_pos = 0
		
	var p = _alive_players[_spectate_cicle_pos]
	p.connect("on_move", self, "_on_player_on_move")
	
	_camera.translation = p.translation
	
func _on_ui_on_exit_click():
	_network_tick.stop()
	Network.disconnect_from_server()
	
################################################################
# player signal handle event
func _on_player_on_falling(_node):
	if is_instance_valid(_player.lock_on_point):
		_player.lock_on_point.highlight(false)
		
	_camera.translation = _node.translation
	
################################################################







