extends Node

const PERSISTEN_SAVE = false

# Called when the node enters the scene tree for the first time.
func _ready():
	load_player_data()
	load_player_ships()
	load_player_selected_ship()
	load_player_selected_mission()
	load_player_missions()
	
################################################################
# player ship & equipment
var player_data = {}
	
func new_player_data() -> Dictionary:
	return {
		id = GDUUID.v4(),
		name = RandomNameGenerator.generate(),
		color = Color.white,
		cash = 100
	}
	
func save_player_data():
	if PERSISTEN_SAVE:
		SaveLoad.save("player.dat", player_data)
	
func load_player_data():
	var _player_data = null 
	
	if PERSISTEN_SAVE:
		_player_data = SaveLoad.load_save("player.dat")
		
	if not _player_data:
		_player_data = new_player_data()
		save_player_data()
		
	player_data = _player_data
	
################################################################
# ship list
var ship_list = []
	
func started_ships():
	var ship_list = []
	for i in Ships.SHIP_LIST:
		var ship = i.duplicate()
		ship.id = GDUUID.v4()
		ship.owner_id = player_data.id
		ship.player_name = Global.player_data.name
		
		ship_list.append(ship)
		
	return ship_list
	
func load_player_ships():
	var _ship_list = null
	
	if PERSISTEN_SAVE:
		_ship_list = SaveLoad.load_save("ship_list.dat")
	
	if not _ship_list:
		_ship_list = started_ships()
		
	ship_list  = _ship_list
	
func update_player_ships(_current_ship):
	var pos = 0
	for i in ship_list:
		if i.id == _current_ship.id:
			break
		pos += 1
		
	ship_list[pos] = _current_ship
	save_player_ships(ship_list)
	
func save_player_ships(_ship_list):
	if PERSISTEN_SAVE:
		SaveLoad.save("ship_list.dat", _ship_list)
	
################################################################
# player ship & equipment
var selected_ship = {}
	
func save_player_selected_ship():
	if selected_ship.empty():
		return
		
	if PERSISTEN_SAVE:
		SaveLoad.save("ship.dat", selected_ship)
	
func load_player_selected_ship():
	var _selected_ship = null 
		
	if PERSISTEN_SAVE:
		_selected_ship = SaveLoad.load_save("ship.dat")
		
	if not _selected_ship:
		_selected_ship = ship_list[0]
		
	selected_ship  = _selected_ship
	
func is_ship_ok() -> bool:
	if selected_ship.hp < selected_ship.max_hp:
		return false
		
#	if selected_ship.weapons.empty():
#		return false
#
#	for i in selected_ship.weapons:
#		if i.ammo <= 0:
#			return false
#
	return true
################################################################
# player mission
var selected_mission = {}
	
func save_player_selected_mission():
	if selected_mission.empty():
		return
		
	if PERSISTEN_SAVE:
		SaveLoad.save("mission.dat", selected_mission)
	
func load_player_selected_mission():
	var _selected_mission = null 
		
	if PERSISTEN_SAVE:
		_selected_mission = SaveLoad.load_save("mission.dat")
		
	if not _selected_mission:
		_selected_mission = {}
		
	selected_mission  = _selected_mission
################################################################
# mission list
var mission_list = []
	
func started_missions():
	var mission_list = []
	for i in 5:
		mission_list.append(
			Missions.generate_operation(Missions.EASY)
		)
		
	for i in 4:
		mission_list.append(
			Missions.generate_operation(Missions.MEDIUM)
		)
		
	for i in 3:
		mission_list.append(
			Missions.generate_operation(Missions.HARD)
		)
		
	for i in 2:
		mission_list.append(
			Missions.generate_operation(Missions.EXTREME)
		)
		
	return mission_list
	
func load_player_missions():
	var _mission_list = null
	
	if PERSISTEN_SAVE:
		_mission_list = SaveLoad.load_save("mission_list.dat")
	
	if not _mission_list:
		_mission_list = started_missions()
		
	mission_list  = _mission_list
	
func update_player_missions(_current_mission):
	var pos = 0
	for i in mission_list:
		if i.id == _current_mission.id:
			break
		pos += 1
		
	mission_list[pos] = _current_mission
	save_player_ships(mission_list)
	
func save_player_missions(_mission_list):
	if PERSISTEN_SAVE:
		SaveLoad.save("mission_list.dat", _mission_list)
	
################################################################
# multiplayer connection and data
const MODE_HOST = 0
const MODE_JOIN = 1
var mode = MODE_HOST

var server = {
	ip = '127.0.0.1',
	port = 31400,
	max_player = 4,
}
var client = {
	ip = '',
	port = 31400,
	network_unique_id = 0,
}

var mp_players_data = []
var mp_battle_result = {}
var mp_exception_message = ""

################################################################















