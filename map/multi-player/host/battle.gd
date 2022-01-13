extends MP_Battle

onready var _camera = $cameraPivot
onready var _terrain = $terrain
onready var _cursor = $cursor

# Called when the node enters the scene tree for the first time.
func _ready():
	init_host()
	
	# all own by server
	$player_1.set_network_master(1)
	$player_2.set_network_master(1)
	
	$player_1.connect("on_move", self, "_on_player_on_move")
	
func init_host():
	Network.connect("server_player_connected", self ,"_server_player_connected")
	Network.connect("player_connected", self , "_player_connected")
	
	var err = Network.create_server(Network.MAX_PLAYERS, Network.DEFAULT_PORT ,Global.selected_ship)
	if err != OK:
		return
		
func _server_player_connected(_player_network_unique_id : int, _player : Dictionary):
	_terrain.generate()
	
	
remote func _request_terrain_data(from_id : int):
	if not get_tree().is_network_server():
		return
		
	rpc_id(
		from_id,
		"_receive_terrain_data",
		_terrain.unused_translations,
		_terrain.feature_translations,
		_terrain.features,
		_terrain.season
	)
	
remote func _move(node_path : NodePath,translation : Vector3):
	get_node(node_path).waypoint = translation
	
	
func _player_connected(player_network_unique_id):
	print(str(player_network_unique_id) + " Joined")
	
	
	
# player movement
func _on_terrain_on_ground_clicked(_translation):
	_cursor.translation = _translation
	_cursor.show()
	_move($player_1.get_path(), _translation)
	
func _on_player_on_move(_node, _translation):
	_camera.translation = _translation
	










