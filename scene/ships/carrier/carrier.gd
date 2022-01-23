extends "res://scene/ships/cruiser/cruiser.gd"

func set_skin(_camo : String = ""):
	$pivot/body_1.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/body_2.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/body_3.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/body_4.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_1.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_2.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_3.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_4.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_5.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_6.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_7.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_8.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_9.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_10.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_11.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/bridge_12.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
