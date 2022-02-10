extends "res://scene/ships/cruiser/cruiser.gd"

func set_skin(_camo : String = ""):
	$pivot/body_1.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/body_2.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/body_3.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	$pivot/body_4.texture = load("res://skin/ships/beam/"+ _camo + "/" +"beam.png")
	
	if _camo == "w-camo":
		$pivot/body_1.modulate = Color(0.486275, 0.913725, 0.972549)
		$pivot/body_2.modulate = Color(0.486275, 0.913725, 0.972549)
		$pivot/body_3.modulate = Color(0.486275, 0.913725, 0.972549)
		$pivot/body_4.modulate = Color(0.486275, 0.913725, 0.972549)
		
	if _camo == "g-camo":
		$pivot/body_1.modulate = Color(0.107391, 0.597656, 0.195486)
		$pivot/body_2.modulate = Color(0.107391, 0.597656, 0.195486)
		$pivot/body_3.modulate = Color(0.107391, 0.597656, 0.195486)
		$pivot/body_4.modulate = Color(0.107391, 0.597656, 0.195486)
	
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
