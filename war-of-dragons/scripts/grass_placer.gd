@tool
extends MultiMeshInstance3D

@export var grass_count: int = 500
@export var spread: Vector2 = Vector2(2.0, 2.0)  # Match your PlaneMesh size (default is 2x2)
@export var blade_width: float = 0.05
@export var blade_height: float = 0.3
@export var min_scale: float = 0.8
@export var max_scale: float = 1.2
@export var interaction_radius: float = 1.0
@export var interaction_push: float = 1.0
## Click this in the Inspector to regenerate grass
@export var regenerate: bool = false:
	set(value):
		regenerate = false
		_generate_grass()

## Wind noise texture — assign a NoiseTexture2D for wind and color variation
@export var noise_texture: Texture2D

var grass_material: ShaderMaterial

func _ready() -> void:
	_generate_grass()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_update_entity_positions()

func _generate_grass() -> void:
	# 1. Create the MultiMesh resource
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = grass_count

	# 2. Create the grass blade mesh with the grass shader
	var quad = QuadMesh.new()
	quad.size = Vector2(blade_width, blade_height)
	# Bottom-pivot so blades sit on the ground
	quad.center_offset = Vector3(0.0, blade_height / 2.0, 0.0)

	grass_material = ShaderMaterial.new()
	grass_material.shader = load("res://shaders/grass.gdshader")

	# Assign noise texture if provided
	if noise_texture:
		grass_material.set_shader_parameter("wind_noise", noise_texture)

	grass_material.set_shader_parameter("interaction_radius", interaction_radius)
	grass_material.set_shader_parameter("interaction_push", interaction_push)

	quad.surface_set_material(0, grass_material)
	mm.mesh = quad

	# 3. Place each instance randomly on the Plain
	for i in range(grass_count):
		var t = Transform3D()

		var x = randf_range(-spread.x / 2.0, spread.x / 2.0)
		var z = randf_range(-spread.y / 2.0, spread.y / 2.0)

		# Random Y-axis rotation so blades face different directions
		var angle = randf_range(0.0, TAU)
		t = t.rotated(Vector3.UP, angle)

		# Random scale variation
		var s = randf_range(min_scale, max_scale)
		t = t.scaled(Vector3(s, s, s))

		# Place at ground level
		t.origin = Vector3(x, 0.0, z)
		mm.set_instance_transform(i, t)

	# 4. Assign the MultiMesh to this node
	multimesh = mm


## Collects the world positions of all Entity nodes in the scene tree
## and passes them to the grass shader for interaction (push/bend).
func _update_entity_positions() -> void:
	if not grass_material:
		return

	var entities = get_tree().get_nodes_in_group("entities")
	# Fallback: if no group defined, find by class
	if entities.is_empty():
		entities = _find_entities(get_tree().root)

	var positions: Array[Vector3] = []
	var max_entities := 16  # must match the array size in the shader
	for entity in entities:
		if positions.size() >= max_entities:
			break
		if entity is Node3D:
			positions.append((entity as Node3D).global_position)

	# Pad to 16 entries (shader expects fixed-size array)
	while positions.size() < max_entities:
		positions.append(Vector3(9999.0, 9999.0, 9999.0))  # far away = no effect

	grass_material.set_shader_parameter("entity_positions", positions)
	grass_material.set_shader_parameter("entity_count", min(entities.size(), max_entities))


## Recursively finds nodes that extend Entity (CharacterBody3D with EntityType)
func _find_entities(node: Node) -> Array[Node]:
	var result: Array[Node] = []
	if node is CharacterBody3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_find_entities(child))
	return result
