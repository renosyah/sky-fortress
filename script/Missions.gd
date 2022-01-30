extends Node
class_name Missions

const TEMPLATE_MISSION = {
	level = 0,
	mission = "",
	hostile_ships = Ships.SHIP_LIST,
	hostile_forts = Forts.FORT_LIST,
	maximum_ship = 1,
	maximum_fort = 1,
	hostile_left = 2,
	hostile_total = 0,
	aggresion = 0.2,
	min_crate = 1,
	max_crate = 1,
	min_cash = 100,
	max_cash = 250
}

static func generate_ship_composition(size : int, multiplier_hp, multiplier_dmg : float) -> Array:
	var ships = []
	for i in size:
		var ship = (Ships.SHIP_LIST[randi() % Ships.SHIP_LIST.size()]).duplicate()
		ship.max_hp += multiplier_hp
		ship.hp = ship.max_hp
		for w in ship.weapons:
			if w.has("damage"):
				w.damage = w.damage * multiplier_dmg
				
		ships.append(ship)
		
	return ships
	
static func generate_fort_composition(size : int, multiplier_hp, multiplier_dmg: float) -> Array:
	var forts = []
	for i in size:
		var fort = (Forts.FORT_LIST[randi() % Forts.FORT_LIST.size()]).duplicate()
		fort.max_hp += multiplier_hp
		fort.hp = fort.max_hp
		for w in fort.weapons:
			if w.has("damage"):
				w.damage = w.damage * multiplier_dmg
				
		forts.append(fort)
		
	return forts

static func generate_missions(size : int) -> Array:
	var missions = []
	var mission = TEMPLATE_MISSION.duplicate()
	var multiplier_hp = 0.0
	var multiplier_dmg = 1.0
	for i in size:
		mission.aggresion += rand_range(0.0, 0.5)
		if mission.aggresion > 0.99:
			mission.aggresion = 1.0
			
		mission.level += 1
		mission.maximum_fort += int(rand_range(0,1))
		if mission.maximum_fort >= 4:
			mission.maximum_fort = 4
		
		mission.maximum_ship += int(rand_range(0,1))
		if mission.maximum_ship >= 4:
			mission.maximum_ship = 4
			
		mission.hostile_total += int(rand_range(1,4))
		if mission.hostile_total >= 8:
			mission.hostile_total = 8
		
		mission.hostile_ships = generate_ship_composition(int(rand_range(1,4)), multiplier_hp, multiplier_dmg)
		mission.hostile_forts = generate_fort_composition(int(rand_range(1,4)), multiplier_hp, multiplier_dmg)
		mission.hostile_left = mission.hostile_total
		mission.max_crate += int(rand_range(1,2))
		mission.min_cash += int(rand_range(10,50))
		mission.max_cash += int(rand_range(20,80))
		mission.mission = "Destroy "+ str(mission.hostile_left) + " Enemy" 
		
		missions.append(mission.duplicate())
		multiplier_hp += round(rand_range(100, 200))
		multiplier_dmg += 0.05
		
	return missions
	
const TEMPLATE_OPERATION = {
	name = "",
	date = "",
	missions = [],
	total_level = 0
}
	
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
	operation.total_level = int(rand_range(3,6))
	operation.missions = generate_missions(operation.total_level)
	
	return operation
	
















