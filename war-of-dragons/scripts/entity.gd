class_name Entity
extends CharacterBody3D

# Use this to categorize Entities
enum EntityType { DRAGON, HOSTILE, COLLECTIBLE, OBSTACLE, BASE }

@export var entity_type: EntityType = EntityType.DRAGON

var is_selected: bool = false
var outline_material: ShaderMaterial

@onready var model = $Model
var meshes: Array[MeshInstance3D] = []

func _ready() -> void:
	outline_material = ShaderMaterial.new()
	outline_material.shader = load("res://shaders/entity_outline.gdshader")
	
	for child in model.find_children("*", "MeshInstance3D", true):
		meshes.append(child)

func set_selected(selected: bool) -> void:
	for mesh in meshes:
		if selected:
			mesh.material_overlay = outline_material
		else:
			mesh.material_overlay = null
