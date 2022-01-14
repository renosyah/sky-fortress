extends Node
class_name MP_Battle

signal player_on_ready(player)

var _aim_mode = false

var _aim_point :Vector3
var _lock_on_point : Spatial

# for every targetable airborne node
var _airborne_targets = []

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
	var _node = get_node(node_path)
	if not is_instance_valid(_node):
		return
		
	_node.waypoint = translation
	
################################################################
# client request to object to
# move at guided aim position
remotesync func _guide_aim(node_path : NodePath, translation : Vector3):
	var _node = get_node(node_path)
	if not is_instance_valid(_node):
		return
		
	_node.translation = translation
	_node.translation.y = 10.0
	

# request to object to
# move at guided aim position
remotesync func _aim(node_path : NodePath, translation : Vector3):
	var _node = get_node(node_path)
	if not is_instance_valid(_node):
		return
		
	_node.aim_point = translation
	

# request to object to
# lock on target node
remotesync func _lock_on(node_path : NodePath, node_path_target : NodePath):
	var _node = get_node(node_path)
	if not is_instance_valid(_node):
		return
		
	var _node_target = get_node(node_path_target)
	if not is_instance_valid(_node_target):
		return
		
	_node.lock_on_point = _node_target
	
################################################################









