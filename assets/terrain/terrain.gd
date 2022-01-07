extends Node
	
signal on_ground_clicked(_translation)
	
const SEASON_LABEL = ["summer","winter"]
const DENSITY = 0.2
	
onready var _input_detection = $inputDetection
	
onready var _season_nodes = {
	"summer" : $ground/season_1,
	"winter" : $ground/season_2
}
onready var _ground_textures = {
	"summer" : Color(0.121569, 0.643137, 0.043137),
	"winter" : Color(0.960784, 0.960784, 0.960784)
}
onready var _feature_holder = $ground/featureHolder
onready var _ground_mesh = $ground/ground/MeshInstance
onready var _templates = $sky/templates
onready var _cloud_holder = $sky/cloudHolder
	
var cloud_spawn_points = []
var _click_translation = Vector3.ZERO

var feature_translations = []
var features = []
var season : String = ""
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
	
func generate():
	randomize()
	if season.empty():
		season = SEASON_LABEL[randi() % SEASON_LABEL.size()]
	
	if features.empty():
		feature_translations = _create_box_shape_translations(Vector3.ZERO, 150)
		features = _generate_new_terrain_features(feature_translations, _season_nodes[season])
	
	_generate_terrain_features(features, _season_nodes[season])
	_set_ground_texture()
	_generate_cloud_translations()
	
func _generate_cloud_translations():
	cloud_spawn_points.clear()
	var _pos_east = _create_z_line_translations($sky/pilars/MeshInstance3.translation)
	var _pos_west = _create_z_line_translations($sky/pilars/MeshInstance.translation)
	cloud_spawn_points.append_array(_pos_east)
	cloud_spawn_points.append_array(_pos_west)
	
func _set_ground_texture():
	var material = SpatialMaterial.new()
	material.albedo_color = _ground_textures[season]
	_ground_mesh.set_surface_material(0,material)
	
func _generate_terrain_features(_feature_data : Array, _season : Spatial):
	for i in _feature_data:
		var _feature = _season.get_node(i.node_name).duplicate()
		_feature.translate(i.node_translation)
		_feature_holder.add_child(_feature)
	
func _generate_new_terrain_features(_box_shape_translations : Array, _season : Spatial) -> Array:
	var _feature_data = []
	if _season.get_children().empty():
		return _feature_data
		
	var _features = _season.get_children()
	for p in _box_shape_translations:
		if randf() < DENSITY:
			randomize()
			var _node_name = _features[randi() % _features.size()].name
			var _node_translation = Vector3(rand_range(p.x - 5.0,p.x + 5.0), 0 ,rand_range(p.z - 5.0,p.z + 5.0))
			_feature_data.append({
				"node_name" : _node_name,
				"node_translation" : _node_translation
			})
			
	return _feature_data
	
	
	
func _create_box_shape_translations(waypoint_position : Vector3 ,number_of_unit : int, space_between_units : int = 10) -> Array:
	var pos = []
	var square_side_size = round(sqrt(number_of_unit))
	var unit_pos = Vector3(waypoint_position.x, 0 ,waypoint_position.z) - space_between_units * Vector3(square_side_size/2,0,square_side_size/2)
	for i in number_of_unit:
		pos.append(unit_pos)
		unit_pos.x += space_between_units
		if unit_pos.x > (waypoint_position.x + square_side_size * space_between_units / 2):
			unit_pos.z += space_between_units
			unit_pos.x = waypoint_position.x - space_between_units * square_side_size / 2
	return pos
	
	
func _create_z_line_translations(_start_point : Vector3) -> Array:
	var pos = []
	var unit_pos = _start_point
	for i in 28:
		pos.append(unit_pos)
		unit_pos.z += 8
	return pos
	
	
func _on_Timer_timeout():
	randomize()
	var p = cloud_spawn_points[randi() % cloud_spawn_points.size()]
	var templates = _templates.get_children()
	var _cloud = templates[randi() % templates.size()].duplicate()
	var new_p = Vector3(rand_range(p.x - 5.0,p.x + 5.0), 0 ,rand_range(p.z - 5.0,p.z + 5.0))
	_cloud.translate(new_p)
	_cloud.translation.y = 10.0
	_cloud.is_move = true
	_cloud.from_right = p.x > 0
	_cloud.random_scale()
	_cloud.random_speed()
	_cloud_holder.add_child(_cloud)
	
	
func _on_ground_input_event(camera, event, position, normal, shape_idx):
	_click_translation = position
	if event is InputEventMouseButton and event.is_action_pressed("left_click"):
		emit_signal("on_ground_clicked", _click_translation)
		
	# if touch screen
	_input_detection.check_input(event)
	
	
func _on_inputDetection_any_gesture(sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("on_ground_clicked", _click_translation)
	











