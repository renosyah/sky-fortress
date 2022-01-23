extends "res://scene/ships/cruiser/cruiser.gd"

func set_skin(_camo : String = ""):
	$pivot/body_1.texture = load("res://skin/ships/baloons/"+ _camo + "/" +"baloon.png")
	$pivot/body_2.texture = load("res://skin/ships/baloons/"+ _camo + "/" +"baloon.png")
	$pivot/body_3.texture = load("res://skin/ships/baloons-large/"+ _camo + "/" +"baloon_large.png")
	$pivot/sail_1.texture = load("res://skin/ships/sails/"+ _camo + "/" +"sail.png")
	$pivot/sail_2.texture = load("res://skin/ships/sails/"+ _camo + "/" +"sail.png")
	$pivot/bridge_1.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_2.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_3.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_4.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_5.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")

	
