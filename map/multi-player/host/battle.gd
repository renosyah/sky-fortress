extends MP_Battle

onready var _camera = $cameraPivot
onready var _terrain = $terrain
onready var _cursor = $cursor
onready var _network_tick = $network_tick
onready var _ui = $ui

var team = "player"

# must be generated
# this will set a purpose on server
# when client want to shot target
# with guided munition
onready var _player_1_aim = $targeting_guide_holder/player_1
onready var _player_2_aim = $targeting_guide_holder/player_2

# must be generated
onready var _player_1 = $airborne_target_holder/player_1
onready var _player_2 = $airborne_target_holder/player_2


# Called when the node enters the scene tree for the first time.
func _ready():
	init_host()
	
	# all own by server
	_player_1.owner_id = "1"
	_player_1.side = "1"
	_player_1.set_network_master(Network.PLAYER_HOST_ID)
	_player_1.aim_point = _player_1_aim.translation
	_player_1.guided_point = _player_1_aim
	_player_1.set_data(Ship.SHIP_LIST[0])
	_player_1.show_hp_bar(false)
	_player_1.set_hp_bar_color(Color.green)
	
	_player_2.owner_id = "2"
	_player_2.side = "2"
	_player_2.set_network_master(Network.PLAYER_HOST_ID)
	_player_2.aim_point = _player_2_aim.translation
	_player_2.guided_point = _player_2_aim
	_player_2.set_data(Ship.SHIP_LIST[0])
	_player_2.show_hp_bar(true)
	_player_2.set_hp_bar_color(Color.blue)
	
	_player_1.connect("on_move", self, "_on_player_on_move")
	_player_1.connect("on_destroyed",_ui,"_on_player_on_destroyed")
	_player_1.connect("on_falling",self,"_on_player_on_falling")
	_player_1.connect("on_falling",_ui,"_on_player_on_falling")
	_player_1.connect("on_spawning_weapon" ,self,"_on_player_on_spawning_weapon")
	_player_1.connect("on_take_damage",_ui,"_on_player_on_take_damage")
	
	
	_airborne_targets.append(_player_1)
	_airborne_targets.append(_player_2)
	
	emit_signal("player_on_ready", _player_1)
	
################################################################
# network connection
func init_host():
	Network.connect("server_player_connected", self ,"_server_player_connected")
	
	var err = Network.create_server(Network.MAX_PLAYERS, Network.DEFAULT_PORT ,Global.selected_ship)
	if err != OK:
		return
	
func _server_player_connected(_player_network_unique_id : int, _player : Dictionary):
	_network_tick.start()
	_terrain.generate()
	
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
	_cursor.translation = _translation
	_cursor.show()
	_move(_player_1.get_path(), _translation)
	
func _on_player_on_move(_node, _translation):
	if not _aim_mode:
		_camera.translation = _translation
	
func _on_cameraPivot_on_camera_moving(_translation, _zoom):
	_aim_point = _translation
	
func _on_cameraPivot_on_body_enter_aim_sight(_body):
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
	if _player_1.has_method("shot"):
		_player_1.shot(_index)
	
################################################################
# player signal handle event
func _on_player_on_spawning_weapon(_node):
	if _node.has_method("take_damage"):
		_airborne_targets.append(_node)
	
func _on_player_on_falling(_node):
	if is_instance_valid(_player_1.lock_on_point):
		_player_1.lock_on_point.highlight(false)
		
	_camera.translation = _node.translation
	_airborne_targets.erase(_node)
	
################################################################


















