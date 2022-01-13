extends Node
class_name MP_Battle

var airborne_targets = []

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
# template for client request object to move
remote func _move(
	node_path : NodePath,
	translation : Vector3
):
	pass
	
################################################################
