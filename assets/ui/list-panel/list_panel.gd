extends Control

signal on_item_press(data)

onready var _container = $ScrollContainer/HBoxContainer

var datas = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_list():
	for i in _container.get_children():
		_container.remove_child(i)
		
	for i in datas:
		var item = preload("res://assets/ui/list-panel/item/item.tscn").instance()
		item.data = i
		_container.add_child(item)
		item.connect("pressed", self ,"_pressed", [item.get_path(), i])
		item.display_item()
	
	
func _pressed(node_path : NodePath, data : Dictionary):
	for i in _container.get_children():
		i.selected(false)
		
	get_node(node_path).selected(true)
	emit_signal("on_item_press", data)
