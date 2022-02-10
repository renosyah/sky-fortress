extends Node
class_name Missions

const EASY = "EASY"
const MEDIUM = "MEDIUM"
const HARD = "HARD"
const EXTREME = "EXTREME"

const DIFFICULTIES = [EASY, MEDIUM, HARD, EXTREME]

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
		var ship = (Ships.SHIP_LIST[randi() % Ships.SHIP_LIST.size()]).duplicate(true)
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
		var fort = (Forts.FORT_LIST[randi() % Forts.FORT_LIST.size()]).duplicate(true)
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
	
const OPERATION_NOT_COMMIT = 0
const OPERATION_SUCCESS = 1
const OPERATION_FAILED = 2

const SEASONS = ["summer", "winter"]

const DESCRIPTIONS = [
	"Clear all enemy airship and ground instalation in the area, intel suggest prepare for heavy fight!",
	"Objective for this operation will be destroy all airship or enemy fort in the area!",
	"Intel report suggest enemy activity in this area are increasing, go there and destroy all posible hostile!",
	"This area has very important resources, go there and clear up the area from enemy present!",
	"Task for this operation, is to destroy posible enemy hostile, beware... enemy present is not something you cant handle with single ship!"
]

const TEMPLATE_OPERATION = {
	id = "",
	name = "",
	date = "",
	description = "",
	season = "summer",
	missions = [],
	total_level = 0,
	difficulty = EASY,
	status = OPERATION_NOT_COMMIT,
	is_selected = false
}


static func generate_operation(difficulty : String = EASY) -> Dictionary:
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
	operation.id = "MISSION-" + str(GDUUID.v4())
	operation.name = "Operation " + RandomNameGenerator.generate()
	operation.date = "%s, %02d %s %d %02d:%02d:%02d GMT" % [nameweekday[dayofweek], day, namemonth[month-1], year, hour, minute, second]
	operation.description = DESCRIPTIONS[randi() % DESCRIPTIONS.size()]
	operation.status = OPERATION_NOT_COMMIT
	operation.difficulty = difficulty
	operation.season = SEASONS[randi() % SEASONS.size()]
	
	match operation.difficulty:
		EASY:
			operation.total_level = int(rand_range(2,4))
			operation.missions = generate_missions(operation.total_level)
		MEDIUM:
			operation.total_level = int(rand_range(4,9))
			operation.missions = generate_missions(operation.total_level)
		HARD:
			operation.total_level = int(rand_range(8,12))
			operation.missions = generate_missions(operation.total_level)
		EXTREME:
			operation.total_level = int(rand_range(12,18))
			operation.missions = generate_missions(operation.total_level)
			
	return operation
	
static func get_total_reward(_operation) -> int:
	var total = 0
	for i in _operation.missions:
		total += i.max_cash
	return total
	
const CONTRACT_NOT_COMMIT = 0
const CONTRACT_SUCCESS = 1
	
const CONTRACT_TYPE_KILL = 0
const CONTRACT_TYPE_BOMBING = 1
const CONTRACT_TYPE_SHOTTING_DOWN = 2

const CONTRACT_TYPES = [CONTRACT_TYPE_KILL, CONTRACT_TYPE_BOMBING,  CONTRACT_TYPE_SHOTTING_DOWN]

const CONTRACT_DESCRIPTIONS = [
	"Want a get paid?",
	"Here is what you need to do..",
	"Bos order, dont question it!",
	"Issue for anyone",
	"Got some hot need here",
	"Good proposition, intresting?"
]

const CONTRACT_COMPLETED_MESSAGES = [
	"Done? good",
	"Here is your payment",
	"Thats more like it",
	"Amazing, see me again if you need work",
	"Nice job",
	"What a supprize"
]

const TITLE_NAMES = ["Sir", "Miss", "Captain", "Leutenant", "General", "Commander" ,"Mrs"]


const TEMPLATE_CONTRACT = {
	id = "",
	name = "",
	description = "",
	completed_message = "",
	subs = [],
	reward = 0,
	status = CONTRACT_NOT_COMMIT,
	is_selected = false
}
const TEMPLATE_SUB_CONTRACT = {
	contract_type = CONTRACT_TYPE_KILL,
	status = CONTRACT_NOT_COMMIT,
	progress = 0,
	goal = 10,
}


static func generate_contract(difficulty : String = EASY) -> Dictionary:
	var contract = TEMPLATE_CONTRACT.duplicate()
	contract.id = "CONTRACT-" + str(GDUUID.v4())
	contract.name = "Issue by " + TITLE_NAMES[randi() % TITLE_NAMES.size()] + " " + RandomNameGenerator.generate()
	contract.description = CONTRACT_DESCRIPTIONS[randi() % CONTRACT_DESCRIPTIONS.size()]
	contract.completed_message = CONTRACT_COMPLETED_MESSAGES[randi() % CONTRACT_COMPLETED_MESSAGES.size()]
	contract.status = CONTRACT_NOT_COMMIT

	var subs = []
	
	match difficulty:
		EASY:
			var total_sub = 1
			for i in total_sub:
				var sub = TEMPLATE_SUB_CONTRACT.duplicate()
				sub.contract_type = CONTRACT_TYPES[randi() % CONTRACT_TYPES.size()]
				sub.status = CONTRACT_NOT_COMMIT
				sub.progress = 0
				sub.goal = int(rand_range(1,5))
				subs.append(sub)
				
			contract.reward = (int(rand_range(150, 200))) * total_sub
		MEDIUM:
			var total_sub = 2
			for i in total_sub:
				var sub = TEMPLATE_SUB_CONTRACT.duplicate()
				sub.contract_type = CONTRACT_TYPES[randi() % CONTRACT_TYPES.size()]
				sub.status = CONTRACT_NOT_COMMIT
				sub.progress = 0
				sub.goal = int(rand_range(6,10))
				subs.append(sub)
				
			contract.reward = (int(rand_range(300, 600))) * total_sub
		HARD:
			var total_sub = int(rand_range(2,3))
			for i in total_sub:
				var sub = TEMPLATE_SUB_CONTRACT.duplicate()
				sub.contract_type = CONTRACT_TYPES[randi() % CONTRACT_TYPES.size()]
				sub.status = CONTRACT_NOT_COMMIT
				sub.progress = 0
				sub.goal = int(rand_range(12,18))
				subs.append(sub)
			
			contract.reward = (int(rand_range(700, 900))) * total_sub
		EXTREME:
			var total_sub = int(rand_range(2,3))
			for i in total_sub:
				var sub = TEMPLATE_SUB_CONTRACT.duplicate()
				sub.contract_type = CONTRACT_TYPES[randi() % CONTRACT_TYPES.size()]
				sub.status = CONTRACT_NOT_COMMIT
				sub.progress = 0
				sub.goal = int(rand_range(18,22))
				subs.append(sub)
			
			contract.reward = (int(rand_range(1000,1500))) * total_sub
			
	contract.subs = subs.duplicate()
	
	return contract



















