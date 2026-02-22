extends Node3D

@onready var camera: Camera3D = $PlayerCameraNode/Marker3D/PlayerCamera
@onready var selection_rect = $SelectionUI/SelectionBox

var selected_units: Array[CharacterBody3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			selection_rect.drag_start = event.position
			selection_rect.drag_end = event.position
			selection_rect.dragging = true
		
		else:
			selection_rect.dragging = false
			var drag_distance = selection_rect.drag_start.distance_to(selection_rect.drag_end)

			# Select one or select many depending on drag distance
			if drag_distance < selection_rect.drag_threshold:
				select_unit(event.position)
			else:
				select_units_in_rectangle()
				
			selection_rect.queue_redraw()
			
	elif event is InputEventMouseMotion and selection_rect.dragging:
		selection_rect.drag_end = event.position
		selection_rect.queue_redraw()
			
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if selected_units.size() > 0:
			command_move(event.position)

func select_unit(mouse_pos: Vector2) -> void:
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	for unit in selected_units:
		unit.set_selected(false)
	
	selected_units.clear()
	
	if result and result.collider.is_in_group("units"):
		var foundUnit = result.collider
		selected_units.append(foundUnit)
		foundUnit.set_selected(true)
		print("Selected:", result.collider.name)

func select_units_in_rectangle():

	var rect = Rect2(selection_rect.drag_start, selection_rect.drag_end - selection_rect.drag_start).abs()

	# Clear previous selection
	for unit in selected_units:
		unit.set_selected(false)

	selected_units.clear()

	# Check all units
	for unit in get_tree().get_nodes_in_group("units"):

		var world_position = unit.global_transform.origin
		var screen_position = camera.unproject_position(world_position)

		if rect.has_point(screen_position):
			unit.set_selected(true)
			selected_units.append(unit)

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
