extends Control

const ITEM = preload("res://assets/ui/server-browser/item/item.tscn")
signal on_join(info)

onready var _item_holder = $VBoxContainer/ScrollContainer/VBoxContainer
onready var _server_list = $VBoxContainer/ScrollContainer
onready var _find_server = $VBoxContainer/Label
onready var _server_listener = $server_listener

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func start_finding():
	show_loading(true)
	_server_listener.setup()
	
func stop_finding():
	show_loading(false)
	_server_listener.stop()
	
func clear_list():
	_server_listener.force_clean_up()
	for i in _item_holder.get_children():
		_item_holder.remove_child(i)
	
func _on_server_listener_new_server(serverInfo):
	show_loading(false)
	var item = ITEM.instance()
	item.info = serverInfo.duplicate()
	item.connect("join", self, "_join")
	_item_holder.add_child(item)
	
func _on_server_listener_remove_server(serverIp):
	show_loading(_item_holder.get_children().empty())
	for child in _item_holder.get_children():
		if child.info["ip"] == serverIp:
			_item_holder.remove_child(child)
			return
	
func _join(info):
	stop_finding()
	emit_signal("on_join", info)
	
	
func show_loading(_show):
	_find_server.visible = _show
	_server_list.visible = not _show
	
	
func _on_exit_pressed():
	clear_list()
	visible = false
	
	
