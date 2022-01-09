extends Spatial

export(Resource) var sprite_resources


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite3D.texture = sprite_resources
	$Sprite3D2.texture = sprite_resources
