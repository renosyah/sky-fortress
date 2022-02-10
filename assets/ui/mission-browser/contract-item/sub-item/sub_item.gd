extends VBoxContainer

onready var _task = $task
onready var _progress = $bar

var sub_contract = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var target = " Enemy Airship or Fort!"
	if sub_contract.contract_type == Missions.CONTRACT_TYPE_BOMBING:
		target = " Enemy Fort!"
	elif sub_contract.contract_type == Missions.CONTRACT_TYPE_SHOTTING_DOWN:
		target = " Enemy Airship!"
		
	_task.text = "Destroy total of " + str(sub_contract.goal) + target
	
	sub_contract.progress = sub_contract.progress if sub_contract.progress < sub_contract.goal else sub_contract.goal
	_progress.update_bar(sub_contract.progress, sub_contract.goal)
