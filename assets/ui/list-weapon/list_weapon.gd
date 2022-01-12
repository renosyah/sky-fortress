extends VBoxContainer

signal on_item_press(data)

onready var _container = $HBoxContainer

var datas = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_list():
	for i in _container.get_children():
		_container.remove_child(i)
		
	var idx = 0
	for i in datas:
		var item = preload("res://assets/ui/list-weapon/item/item.tscn").instance()
		item.connect("pressed", self ,"_pressed")
		item.data = i
		item.index = idx
		_container.add_child(item)
		item.display_item()
		idx += 1
	
func _pressed(index, data):
	emit_signal("on_item_press", index, data)
