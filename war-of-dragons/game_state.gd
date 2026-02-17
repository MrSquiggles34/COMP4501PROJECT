extends Node3D

@onready var camera: Camera3D = $PlayerCameraNode/Marker3D/PlayerCamera

var selected_units: Array[CharacterBody3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			select_unit(event.position)
			
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if selected_units.size() > 0:
				command_move(event.position)

func select_unit(mouse_pos: Vector2) -> void:
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	selected_units.clear()
	
	if result and result.collider.is_in_group("units"):
		selected_units.append(result.collider)
		print("Selected:", result.collider.name)

func command_move(mouse_pos: Vector2) -> void:
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if not result:
		return
	
	var click_position: Vector3 = result.position
	
	# ---- Formation Setup ----
	var unit_count = selected_units.size()
	var spacing = 2.0
	
	# Square grid
	var columns: int = int(ceil(sqrt(float(unit_count))))
	
	for i in range(unit_count):
		var row = i / columns
		var col = i % columns
		
		var offset = Vector3(
			(col - columns / 2.0) * spacing,
			0,
			row * spacing
		)
		
		selected_units[i].move_to(click_position + offset)
