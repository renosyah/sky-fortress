extends MP_Battle

onready var _bot_holder = $bot_airship_holder
onready var _fort_holder = $bot_fort_holder

onready var _event_timer = $event_timer

onready var _camera = $cameraPivot
onready var _terrain = $terrain
onready var _cursor = $cursor
onready var _network_tick = $network_tick
onready var _ui = $ui

onready var _targeting_guide_holder = $targeting_guide_holder
onready var _player_holder = $player_holder

var pos_mission = 0
var missions = []
var mission = {}
var is_over = false

var total_airship_destroyed = 0
var total_fort_destroyed = 0
var total_cash_collected = 0
var cash_obtain = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	missions = Global.selected_mission.missions
	_ui.update_objective(Global.selected_mission, missions[pos_mission])
	_ui.display_mission_objective(Global.selected_mission.name, Global.selected_mission.date, "")
	
	.init_connection_watcher()
	.spawn_players(_player_holder.get_path(), _targeting_guide_holder.get_path(), _ui.get_path())
	
	_ui.set_camera(_camera)
	_network_tick.start()
	
	_terrain.season = Global.selected_mission.season
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
	if not _aim_mode:
		return
		
	._on_body_enter_aim_sight(_body)
	
################################################################
# network tick to send automatic request
func _on_network_tick_timeout():
	if get_tree().network_peer:
		.sync_targeting_system()
	
func _connection_closed():
	._connection_closed()
	_network_tick.stop()
	
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

func add_minimap_object(_node_path : NodePath, _name : String = ""):
	.add_minimap_object(_node_path, _name)
	
	var _node = get_node_or_null(_node_path)
	if not is_instance_valid(_node):
		return
	
	_ui.add_minimap_object(_node, _name)
	
func remove_minimap_object(_node_path : NodePath):
	.remove_minimap_object(_node_path)
	
	var _node = get_node_or_null(_node_path)
	if not is_instance_valid(_node):
		return
		
	_ui.remove_minimap_object(_node)
	
func _on_ui_on_exit_click():
	_network_tick.stop()
	Network.disconnect_from_server()
	get_tree().change_scene("res://menu/main-menu/main_menu.tscn")
	
################################################################
# player signal handle event
func _on_player_on_falling(_node):
	._on_player_on_falling(_node)
	
	if is_instance_valid(_node.lock_on_point):
		_node.lock_on_point.highlight(false)
		
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
# mission manager
func check_player():
	if is_over:
		return
	
	var _alive_players = []
	for i in _player_holder.get_children():
		if not i.destroyed:
			_alive_players.append(i)
		
	if _alive_players.empty():
		# mission fail all players dead
		on_lose()
		
	
func check_mission():
	if is_over:
		return
		
	if mission.empty():
		change_mission()
		return
	
	if mission.hostile_left <= 0:
		change_mission()
	
func change_mission():
	if missions.empty():
		return
		
	if pos_mission > missions.size() - 1:
		# mission completed all mission aquired
		on_victory()
		return
		
	mission = missions[pos_mission]
	_max_hostile_ship = mission.maximum_ship
	_max_hostile_fort = mission.maximum_fort
	_aggresion = mission.aggresion
	_min_crate = mission.min_crate
	_max_crate = mission.max_crate
	_min_cash = mission.min_cash
	_max_cash = mission.max_cash
	
	var reward_message = ""
	if pos_mission > 0:
		reward_message = "Reward : $" +str(_max_cash)
		total_cash_collected += _max_cash
		rpc("_cash_pickup", "", _max_cash)
	
	_ui.update_objective(Global.selected_mission, mission)
	_ui.display_mission_objective("Level " + str(mission.level), mission.mission ,reward_message)
	pos_mission += 1
	
func on_victory():
	is_over = true
	_event_timer.stop()
	rpc("_remove_all_hostile" , [_bot_holder.get_path(), _fort_holder.get_path()])
	_ui.display_mission_result({
			is_win = true,
			total_airship_destroyed = total_airship_destroyed,
			total_fort_destroyed = total_fort_destroyed,
			total_cash_collected = total_cash_collected
		}
	)
	Global.selected_mission.status = Missions.OPERATION_SUCCESS
	Global.save_player_selected_mission()
	Global.update_player_missions(Global.selected_mission)
	Global.selected_mission = {}
	.disconnect_from_server()
	
func on_lose():
	is_over = true
	_event_timer.stop()
	rpc("_remove_all_hostile" , [_bot_holder.get_path(), _fort_holder.get_path()])
	_ui.display_mission_result({
			is_win = false,
			total_airship_destroyed = total_airship_destroyed,
			total_fort_destroyed = total_fort_destroyed,
			total_cash_collected = total_cash_collected
		}
	)
	Global.selected_mission.status = Missions.OPERATION_FAILED
	Global.save_player_selected_mission()
	Global.update_player_missions(Global.selected_mission)
	Global.selected_mission = {}
	.disconnect_from_server()
	
func _on_enemy_fort_on_destroyed(_node):
	._on_enemy_fort_on_destroyed(_node)
	
	if get_tree().is_network_server():
		if mission.empty():
			return
			
		mission.hostile_left -= 1
		total_fort_destroyed += 1
		
		_ui.update_objective(Global.selected_mission, mission)
		_ui.display_mission_objective(
			"Enemy Fort Destroy",
			str(mission.hostile_left) + " Remaining!" if mission.hostile_left > 0 else "Objective Completed!",
			""
		)
	
func _on_enemy_ship_on_destroyed(_node):
	._on_enemy_ship_on_destroyed(_node)
	
	if get_tree().is_network_server():
		if mission.empty():
			return
			
		mission.hostile_left -= 1
		total_airship_destroyed += 1
		
		_ui.update_objective(Global.selected_mission, mission)
		_ui.display_mission_objective(
			"Enemy Airship Destroy",
			str(mission.hostile_left) + " Remaining!" if mission.hostile_left > 0 else "Objective Completed!",
			""
		)
		
func cash_obtain(_amount):
	total_cash_collected += _amount
	
################################################################
# event countdown on host player
# spawning hostile bot
func _on_event_timer_timeout():
	if not get_tree().network_peer:
		return
		
	if _terrain.cloud_spawn_points.empty():
		return
		
	var bots_count = _bot_holder.get_child_count()
	if not mission.empty() and bots_count < _max_hostile_ship:
		var ship_name =  "BOT-" + str(GDUUID.v4())
		var spawn_pos = _terrain.cloud_spawn_points[randi() % _terrain.cloud_spawn_points.size()]
		var ship_data = mission.hostile_ships[randi() % mission.hostile_ships.size()]
		rpc("_spawn_hostile_airship", Network.PLAYER_HOST_ID, ship_name, ship_data, _bot_holder.get_path(),_ui.get_path(), spawn_pos)
	
	var fort_count = _fort_holder.get_child_count()
	if not mission.empty() and fort_count < _max_hostile_fort:
		var fort_name =  "FORT-BOT-" + str(GDUUID.v4())
		var spawn_pos_fort = _terrain.unused_translations[randi() % _terrain.unused_translations.size()]
		var fort_data = mission.hostile_forts[randi() % mission.hostile_forts.size()]
		rpc("_spawn_hostile_fort", Network.PLAYER_HOST_ID, fort_name, fort_data, _fort_holder.get_path(),_ui.get_path(), spawn_pos_fort.node_translation)
		
	check_mission()
	check_player()
	
################################################################
# timeout to bot command to where move and what to shot
func _on_bot_command_timer_timeout():
	give_command_to_move_to_airship_bot(_bot_holder.get_path(), _terrain.get_path())

func _on_bot_shotting_timer_timeout():
	give_command_to_shot_to_airship_bot(_bot_holder.get_path())







