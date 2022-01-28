extends Node
class_name Missions

const TEMPLATE_MISSION = {
	level = 0,
	mission = "",
	hostile_ship = Ships.SHIP_LIST,
	hostile_fort = Forts.FORT_LIST,
	maximum_ship = 1,
	maximum_fort = 1,
	hostile_left = 2,
	hostile_total = 0,
	aggresion = 0.2,
	min_crate = 1,
	max_crate = 1
}

const TEMPLATE_OPERATION = {
	name = "",
	date = "",
	missions = [],
	total_mission = 0
}

static func generate_missions(size : int) -> Array:
	var missions = []
	var mission = TEMPLATE_MISSION.duplicate()
	for i in size:
		mission.aggresion += rand_range(0.0, 0.5)
		if mission.aggresion > 0.99:
			mission.aggresion = 1.0
			
		mission.level += 1
		mission.maximum_fort += int(rand_range(0,2))
		mission.maximum_ship += int(rand_range(0,1))
		mission.hostile_total += int(rand_range(1,4))
		mission.hostile_left = mission.hostile_total
		mission.max_crate += int(rand_range(1,2))
		mission.mission = "Destroy "+ str(mission.hostile_left) + " Enemy" 
		
		missions.append(mission.duplicate())
		
	return missions

static func generate_operation() -> Dictionary:
	var time = OS.get_datetime()
	var nameweekday= ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	var namemonth= ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	var dayofweek = time["weekday"]
	var day = time["day"]
	var month= time["month"]
	var year= time["year"]             
	var hour= time["hour"]
	var minute= time["minute"]
	var second= time["second"] 
	
	var operation = TEMPLATE_OPERATION.duplicate()
	operation.name = "Operation " + RandomNameGenerator.generate()
	operation.date = "%s, %02d %s %d %02d:%02d:%02d GMT" % [nameweekday[dayofweek], day, namemonth[month-1], year, hour, minute, second]
	operation.total_mission = int(rand_range(3,15))
	operation.missions = generate_missions(operation.total_mission)
	
	return operation

















