extends Node

var selected_ship = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var _selected_ship = SaveLoad.load_save("ship.dat")
	if not _selected_ship:
		_selected_ship = Ship.SHIP_LIST[0]
		
	selected_ship  = _selected_ship
