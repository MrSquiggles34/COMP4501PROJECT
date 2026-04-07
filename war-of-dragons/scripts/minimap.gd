extends Control

@export var minimap_rect: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var minimap_viewport: SubViewport = get_tree().current_scene.get_node("MinimapViewport")
	
	if minimap_rect:
		minimap_rect.texture = minimap_viewport.get_texture()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
