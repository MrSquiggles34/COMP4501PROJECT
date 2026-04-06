extends Node3D

@onready var sprite := $Sprite3D
@onready var viewport := $SubViewport
@onready var bar := $SubViewport/HealthBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = viewport.get_texture()
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_health(new_health: float):
	bar.update_bar(new_health)

func init_health(max_health: float):
	bar.init_bar(max_health)
