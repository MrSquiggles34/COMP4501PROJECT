extends Node3D

@onready var camera: Camera3D = $PlayerCameraNode/Marker3D/PlayerCamera
@onready var selection_rect = $SelectionUI/SelectionBox
@onready var entities_container = $Map/Entities

var entities: Array[Entity] = []
var selected_entities: Array[Entity] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Retrieve all the entities in the scene
	entities = get_all_entities(entities_container)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_all_entities(node: Node) -> Array[Entity]:
	var result: Array[Entity] = []
	for child in node.get_children():
		if child is Entity:
			result.append(child)
		if child.get_child_count() > 0:
			result += get_all_entities(child)  
	return result

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
		if selected_entities.size() > 0:
			command_move(event.position)

func select_unit(mouse_pos: Vector2) -> void:
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	for entity in selected_entities:
		entity.set_selected(false)
	
	selected_entities.clear()
	
	if result and result.collider is Entity:
		var foundUnit = result.collider
		selected_entities.append(foundUnit)
		foundUnit.set_selected(true)
		print("Selected:", result.collider.name)

func select_units_in_rectangle():

	var rect = Rect2(selection_rect.drag_start, selection_rect.drag_end - selection_rect.drag_start).abs()

	# Clear previous selection
	for entity in entities:
		entity.set_selected(false)

	selected_entities.clear()

	# Check all units
	for entity in entities:
		if entity.entity_type != Entity.EntityType.DRAGON:
			continue

		var world_position = entity.global_transform.origin
		var screen_position = camera.unproject_position(world_position)

		if rect.has_point(screen_position):
			entity.set_selected(true)
			selected_entities.append(entity)

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
	var unit_count = selected_entities.size()
	var spacing = 2.0
	
	# Square grid
	var columns: int = int(ceil(sqrt(float(unit_count))))
	
	for i in range(selected_entities.size()):
		var row = i / columns
		var col = i % columns
		
		var offset = Vector3(
			(col - columns / 2.0) * spacing,
			0,
			row * spacing
		)
		
		if selected_entities[i] is Dragon:
			selected_entities[i].move_to(click_position + offset)
