extends Node3D

@export var map_icon: Texture

@onready var icon_sprite: Sprite3D = $IconSprite

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if map_icon:
		icon_sprite.texture = map_icon
	
	# 524288 is Layer 20 (map_icons)
	icon_sprite.layers = 524288 

func _process(_delta: float) -> void:
	# If you want it to always stay flat even if the parent rotates on X or Z:
	global_rotation.x = 0
	global_rotation.z = 0
