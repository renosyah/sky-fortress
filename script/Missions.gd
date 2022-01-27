extends Node
class_name Missions

const TEMPLATE = {
	level = 0,
	mission = "",
	hostile_ship = Ships.SHIP_LIST,
	hostile_fort = Forts.FORT_LIST,
	maximum_ship = 1,
	maximum_fort = 2,
	hostile_left = 3,
	aggresion = 0.3,
	min_crate = 1,
	max_crate = 2
}

static func generate_missions(size : int) -> Array:
	var missions = []
	var mission = TEMPLATE.duplicate()
	for i in size:
		mission.aggresion += 0.1
		if mission.aggresion > 0.8:
			mission.aggresion = 0.8
			
		mission.level += 1
		mission.maximum_fort += int(rand_range(0,1))
		mission.maximum_ship += int(rand_range(0,1))
		mission.hostile_left += int(rand_range(1,3))
		mission.max_crate += int(rand_range(1,2))
		mission.mission = "Destroy "+ str(mission.hostile_left) + " Enemy" 
		
		missions.append(mission.duplicate())
	
	return missions
