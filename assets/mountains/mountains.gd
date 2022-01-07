extends Spatial

export(Resource) var sprite_resources

onready var _sprite3d = $Sprite3D

# Called when the node enters the scene tree for the first time.
func _ready():
	_sprite3d.texture = sprite_resources
