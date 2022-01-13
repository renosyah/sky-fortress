extends Node
class_name MP_Battle

var _aim_mode = false

var _aim_point :Vector3
var _lock_on : Spatial

var _airborne_targets = []

################################################################
# template for client request terrain data section
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
# client request object to move
remote func _move(node_path : NodePath,translation : Vector3):
	get_node(node_path).waypoint = translation
	
################################################################
# client request to object to
# move at guided aim position
remotesync func _guide_aim(node_path : NodePath,translation : Vector3):
	get_node(node_path).translation = translation
	get_node(node_path).translation.y = 10.0
	
################################################################
# client request to object to
# move at guided aim position
remotesync func _aim(node_path : NodePath,translation : Vector3):
	get_node(node_path).aim_point = translation
	
################################################################
# client request to object to lock on
remotesync func _lock_on(node_path : NodePath,node_path_target : NodePath):
	get_node(node_path).lock_on_point = get_node(node_path_target)
	
################################################################









