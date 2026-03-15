extends Node3D

@onready var camera: Camera3D = $PlayerCameraNode/Marker3D/PlayerCamera
@onready var selection_rect = $SelectionUI/SelectionBox
@onready var game_interface = $GameInterfaceLayer
@onready var dragons_label = $GameInterfaceLayer/GameInterface/CenterContainer/VBoxContainer/DragonsLabel
@onready var enemies_label = $GameInterfaceLayer/GameInterface/CenterContainer/VBoxContainer/EnemiesLabel
@onready var entities_container = $Map/Entities

#NOTE: Before accessing these arrays, you should call clean_entities()
var entities: Array[Entity] = []
var selected_entities: Array[Entity] = []

var save_path := "res://savegame.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	initialize_game(Global.load_from_save)

func initialize_game(is_loading: bool) -> void:
	if is_loading and FileAccess.file_exists(save_path):
		load_game()
	else:
		start_new_game()
		save_game() # Automatically create save file on new game setup
		
	# Refresh entities list after setup or load
	entities = get_all_entities(entities_container)

func start_new_game() -> void:
	# Define beginning parameters for a new game.
	# For example: start with only 1 Dragon unit
	var dragons_container = $Map/Entities/DynamicEntity/Dragons
	var hostiles_container = $Map/Entities/DynamicEntity/Hostiles
	
	# We remove all predefined dragons except the first one
	var all_dragons = dragons_container.get_children()
	if all_dragons.size() > 3:
		
		# Queue remaining dragons for deletion
		for i in range(3, all_dragons.size()):
			all_dragons[i].queue_free()
	
	# We remove all predefined hostiles except the first one
	var all_hostiles = hostiles_container.get_children()
	if all_hostiles.size() > 4:
		
		# Queue remaining hostiles for deletion
		for i in range(4, all_hostiles.size()):
			all_hostiles[i].queue_free()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		if has_node("Map") and $Map.has_method("save_collectibles_sync"):
			$Map.save_collectibles_sync()
		get_tree().quit()

func save_game() -> void:
	# Keep entities array up to date before saving
	clean_entities()
	entities = get_all_entities(entities_container)
	
	var save_data = {}
	if FileAccess.file_exists(save_path):
		var file_read = FileAccess.open(save_path, FileAccess.READ)
		if file_read:
			var text = file_read.get_as_text()
			file_read.close()
			var json = JSON.new()
			if json.parse(text) == OK and typeof(json.data) == TYPE_DICTIONARY:
				save_data = json.data
				
	save_data["dragons"] = []
	save_data["hostiles"] = []
	
	for entity in entities:
		if not is_instance_valid(entity) or entity.is_queued_for_deletion():
			continue
			
		if entity is Dragon:
			var dragon_data = {
				"type": Dragon.DragonType.keys()[entity.dragon_type],
				"x": entity.global_position.x,
				"y": entity.global_position.y,
				"z": entity.global_position.z
			}
			save_data["dragons"].append(dragon_data)
		elif entity is Hostile:
			var hostile_data = {
				"type": Hostile.HostileType.keys()[entity.hostile_type],
				"x": entity.global_position.x,
				"y": entity.global_position.y,
				"z": entity.global_position.z
			}
			save_data["hostiles"].append(hostile_data)
			
	var json_string = JSON.stringify(save_data)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()

func load_game() -> void:
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return
		
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
		
	var save_data = json.data
	
	var dragons_container = $Map/Entities/DynamicEntity/Dragons
	var hostiles_container = $Map/Entities/DynamicEntity/Hostiles
	var collectibles_container = $Map/Entities/Collectibles
	
	# Clear out existing units before loading
	for child in dragons_container.get_children():
		child.queue_free()
	for child in hostiles_container.get_children():
		child.queue_free()
	for child in collectibles_container.get_children():
		child.queue_free()
		
	# We need to spawn units. We need the Dragon and Hostile scenes.
	var dragon_fly_scene = load("res://scenes/dragon_fly.tscn")
	var dragon_burrow_scene = load("res://scenes/dragon_burrow.tscn")
	var dragon_ground_scene = load("res://scenes/dragon_ground.tscn")
	var hostile_flytrap_scene = load("res://scenes/hostile_flytrap.tscn")
	var hostile_golem_scene = load("res://scenes/hostile_golem.tscn")
	var hostile_slime_scene = load("res://scenes/hostile_slime.tscn")
	var hostile_mushroom_scene = load("res://scenes/hostile_mushroom.tscn")
	
	var collectible_scene = load("res://scenes/collectible.tscn")
	
	if save_data.has("dragons"):
		for dragon_data in save_data["dragons"]:
			var dragon_scene
			
			match dragon_data["type"]:
				"GROUND":
					dragon_scene = dragon_ground_scene
				"FLY":
					dragon_scene = dragon_fly_scene
				"BURROW":
					dragon_scene = dragon_burrow_scene
					
			var new_dragon = dragon_scene.instantiate()
			dragons_container.add_child(new_dragon)
			
			new_dragon.global_position = Vector3(dragon_data["x"], dragon_data["y"], dragon_data["z"])
			
	if save_data.has("hostiles"):
		for hostile_data in save_data["hostiles"]:
			var hostile_scene
			
			match hostile_data["type"]:
				"MUSHROOM":
					hostile_scene = hostile_mushroom_scene
				"SLIME":
					hostile_scene = hostile_slime_scene
				"FLYTRAP":
					hostile_scene = hostile_flytrap_scene
				"GOLEM":
					hostile_scene = hostile_golem_scene
					
			var new_hostile = hostile_scene.instantiate()
			hostiles_container.add_child(new_hostile)
			
			new_hostile.global_position = Vector3(hostile_data["x"], hostile_data["y"], hostile_data["z"])
			
	if save_data.has("collectibles"):
		for c_data in save_data["collectibles"]:
			var new_collectible = collectible_scene.instantiate()
			collectibles_container.add_child(new_collectible)
			new_collectible.global_position = Vector3(c_data["pos_x"], c_data["pos_y"], c_data["pos_z"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_interface"):
		game_interface.visible = not game_interface.visible
		if game_interface.visible:
			_update_interface_stats()

func _update_interface_stats() -> void:
	clean_entities()
	entities = get_all_entities(entities_container)
	
	var d_count = 0
	var h_count = 0
	for entity in entities:
		if is_instance_valid(entity) and not entity.is_queued_for_deletion():
			if entity.entity_type == Entity.EntityType.DRAGON:
				d_count += 1
			elif entity.entity_type == Entity.EntityType.HOSTILE:
				h_count += 1
				
	dragons_label.text = "Dragons: " + str(d_count)
	enemies_label.text = "Enemies: " + str(h_count)

func _on_quit_to_menu_button_pressed() -> void:
	save_game()
	if has_node("Map") and $Map.has_method("save_collectibles_sync"):
		$Map.save_collectibles_sync()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

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
			var from = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * 1000.0
			
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(query)
			
			if not result:
				return
			
			var clicked_entity = result.collider
			var click_position: Vector3 = result.position
			
			if clicked_entity is Hostile:
				# Attack the hostile with all selected dragons
				for entity in selected_entities:
					if entity is Dragon:
						entity.attack(clicked_entity)
			elif clicked_entity is Collectible:
				#move dragons to collectible to start carrying
				for entity in selected_entities:
					if entity is Dragon:
						entity.carry(clicked_entity)
			else:
				# Regular move if clicked on ground
				var unit_count = selected_entities.size()
				var spacing = 2.0
				var columns: int = int(ceil(sqrt(float(unit_count))))
				
				for i in range(unit_count):
					var row = i / columns
					var col = i % columns
					
					var offset = Vector3(
						(col - columns / 2.0) * spacing,
						0,
						row * spacing
					)
					
					if selected_entities[i] is Dragon:
						selected_entities[i].move_to(click_position + offset)

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
	clean_entities()

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

# Remove an entity from the game REQUIRED FOR ACCESSING ENTITY ARRAYS
func clean_entities():
	var i = 0
	while i < entities.size():
		if not is_instance_valid(entities[i]):
			entities.remove_at(i)
		else:
			i += 1

	i = 0
	while i < selected_entities.size():
		if not is_instance_valid(selected_entities[i]):
			selected_entities.remove_at(i)
		else:
			i += 1
