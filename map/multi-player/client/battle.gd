extends MP_Battle

onready var _camera = $cameraPivot
onready var _terrain = $terrain
onready var _cursor = $cursor

# Called when the node enters the scene tree for the first time.
func _ready():
	init_client()
	
	$player_2.connect("on_move", self, "_on_player_on_move")
	
func init_client():
	Network.connect("client_player_connected", self , "_client_player_connected")
	Network.connect("player_connected", self , "_player_connected")
	
	var err = Network.connect_to_server(Network.DEFAULT_IP, Network.DEFAULT_PORT, Global.selected_ship)
	if err != OK:
		return
		
	
func _client_player_connected(player_network_unique_id : int, player : Dictionary):
	rpc_id(Network.PLAYER_HOST_ID,"_request_terrain_data", player_network_unique_id)
	
	
remote func _receive_terrain_data(unused_translations :Array,feature_translations :Array,features :Array,season : String):
	if get_tree().is_network_server():
		return
		
	_terrain.unused_translations = unused_translations
	_terrain.feature_translations = feature_translations
	_terrain.features = features
	_terrain.season = season
	
	_terrain.generate()
	
	
func _player_connected(player_network_unique_id):
	print(str(player_network_unique_id) + " Joined")
	
	
	
# player movement
func _on_terrain_on_ground_clicked(_translation):
	_cursor.translation = _translation
	_cursor.show()
	rpc_id(Network.PLAYER_HOST_ID,"_move", $player_2.get_path(),_translation)
	
func _on_player_on_move(_node, _translation):
	_camera.translation = _translation
	
	
