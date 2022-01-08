extends TextureProgress

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_bar(hp, max_hp):
	max_value = max_hp
	value = hp
	$RichTextLabel.text = str(hp) + "/" + str(max_hp)
	
func set_hp_bar_color(_color : Color):
	tint_progress = _color
