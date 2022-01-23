extends Node

const PERSISTEN_SAVE = false

# Called when the node enters the scene tree for the first time.
func _ready():
	load_player_data()
	load_player_ships()
	load_player_selected_ship()
	load_last_battle_result()
	
################################################################
# player ship & equipment
var player_data = {}
	
func new_player_data() -> Dictionary:
	return {
		id = GDUUID.v4(),
		name = RandomNameGenerator.generate(),
		color = Color.white
	}
	
func save_player_data(_data):
	if PERSISTEN_SAVE:
		SaveLoad.save("player.dat", _data)
	
func load_player_data():
	var _player_data = null 
	
	if PERSISTEN_SAVE:
		_player_data = SaveLoad.load_save("player.dat")
		
	if not _player_data:
		_player_data = new_player_data()
		save_player_data(_player_data)
		
	player_data = _player_data
	
################################################################
# ship list
var ship_list = []
	
func started_ships():
	return Ships.SHIP_LIST.duplicate(true)
	
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
	
func save_player_selected_ship(_selected_ship):
	if PERSISTEN_SAVE:
		SaveLoad.save("ship.dat", _selected_ship)
	
func load_player_selected_ship():
	var _selected_ship = null 
		
	if PERSISTEN_SAVE:
		_selected_ship = SaveLoad.load_save("ship.dat")
		
	if not _selected_ship:
		for i in ship_list:
			i.owner_id = player_data.id
			i.player_name = Global.player_data.name
			
		_selected_ship = ship_list[0]
		
	selected_ship  = _selected_ship
	
################################################################
# player battle result
# { enemy_kill : 0 }
var battle_result = null
	
func load_last_battle_result():
	var _result = SaveLoad.load_save("battle.dat")
	SaveLoad.delete_save("battle.dat")
	battle_result  = _result
	
func update_battle_result(_result):
	SaveLoad.save("battle.dat", _result)
	
################################################################
# multiplayer connection and data
const MODE_HOST = 0
const MODE_JOIN = 1
var mode = MODE_HOST

var server = {
	ip = '127.0.0.1',
	port = 31400,
	max_player = 6,
}
var client = {
	ip = '',
	port = 31400,
	network_unique_id = 0,
}

var mp_battle_data = {}
var mp_players_data = []

################################################################















