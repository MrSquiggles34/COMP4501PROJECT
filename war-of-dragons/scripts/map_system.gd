extends Node

var save_path := "res://savegame.json"
var save_timer: Timer

func _ready() -> void:
	save_timer = Timer.new()
	save_timer.wait_time = 60.0
	save_timer.autostart = true
	save_timer.timeout.connect(save_collectibles_async)
	add_child(save_timer)
	
	_setup_mud_area()
	_setup_rock_area()

var game_timer_started := false
var game_time_remaining := 300.0
var game_over_triggered := false

@onready var anim_player: AnimationPlayer = $WorldEnvironment/AnimationPlayer

func _setup_mud_area() -> void:
	var mud_static = get_node_or_null("NavigationRegion3D/MudRegion")
	if not mud_static:
		return
		
	# Create Area3D for mud detection dynamically since we can't edit the large .tscn file easily
	var area = Area3D.new()
	area.name = "MudDetectionArea"
	mud_static.add_child(area)
	
	# Copy collision shape
	var source_col = mud_static.get_node_or_null("CollisionShape3D")
	if source_col:
		var new_col = CollisionShape3D.new()
		new_col.shape = source_col.shape
		area.add_child(new_col)
	
	area.body_entered.connect(_on_mud_body_entered)
	area.body_exited.connect(_on_mud_body_exited)

func _on_mud_body_entered(body: Node3D) -> void:
	if body is Dragon:
		if body.dragon_type == Dragon.DragonType.GROUND or body.dragon_type == Dragon.DragonType.BURROW:
			print("Dragon entering mud: ", body.name)
			body.speed_multiplier = 0.3

func _on_mud_body_exited(body: Node3D) -> void:
	if body is Dragon:
		if body.dragon_type == Dragon.DragonType.GROUND or body.dragon_type == Dragon.DragonType.BURROW:
			print("Dragon exiting mud: ", body.name)
			body.speed_multiplier = 1.0

func _setup_rock_area() -> void:
	var rock_area = get_node_or_null("NavigationRegion3D/RockRegion")
	if not rock_area:
		return
		
	# Create a StaticBody3D that only the burrow dragon will collide with
	var blocker = StaticBody3D.new()
	blocker.name = "BurrowBlocker"
	# Layer 2 (Bit 1) is reserved for blocking burrowing movement
	blocker.collision_layer = 2 
	blocker.collision_mask = 0
	rock_area.add_child(blocker)
	
	# Copy detection shape from Area3D
	var source_col = rock_area.get_node_or_null("CollisionShape3D")
	if source_col:
		var new_col = CollisionShape3D.new()
		new_col.shape = source_col.shape
		blocker.add_child(new_col)

func _process(delta: float) -> void:
	if game_over_triggered:
		return
		
	if not game_timer_started:
		if anim_player.is_playing() and anim_player.current_animation == "daynightcycle": #not working for some reason
			#if anim_player.current_animation_position >= 30.0: # prep time
			game_timer_started = true
			print("Starting game timer")
		
	else:
		game_time_remaining -= delta
		#print("Attempting to update game timer")
		_update_ui_timer()
		
		if game_time_remaining <= 0:
			game_time_remaining = 0
			_trigger_game_over()

func _update_ui_timer() -> void:
	var ui = get_parent().get_node_or_null("UILayer/UI")
	if ui and ui.has_node("CenterContainer/VBoxContainer/TimerLabel"):
		var label = ui.get_node("CenterContainer/VBoxContainer/TimerLabel")
		var minutes := int(game_time_remaining) / 60
		var seconds := int(game_time_remaining) % 60
		print("The label should be updated")
		label.text = "%d:%02d" % [minutes, seconds]

func _trigger_game_over() -> void:
	game_over_triggered = true
	var ui = get_parent().get_node_or_null("UI")
	if ui and ui.has_node("GameOverOverlay"):
		ui.get_node("GameOverOverlay").visible = true
	
	# Wait 5 seconds, save, then exit
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(_finalize_game_over)

func _finalize_game_over() -> void:
	# Save game via GameState
	var game_state = get_parent()
	if game_state.has_method("save_game"):
		game_state.save_game()
	
	# Save collectibles
	save_collectibles_sync()
	
	# Exit to main menu
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func save_collectibles_async() -> void:
	var col_data = _gather_collectibles()
	WorkerThreadPool.add_task(_write_collectibles.bind(col_data), true)

func save_collectibles_sync() -> void:
	var col_data = _gather_collectibles()
	_write_collectibles(col_data)

func _gather_collectibles() -> Array:
	var data = []
	if has_node("Entities/Collectibles"):
		for c in $Entities/Collectibles.get_children():
			data.append({
				"name": c.name,
				"pos_x": c.global_position.x,
				"pos_y": c.global_position.y,
				"pos_z": c.global_position.z
			})
	return data

func _write_collectibles(col_data: Array) -> void:
	var existing_data = {}
	if FileAccess.file_exists(save_path):
		var file_read = FileAccess.open(save_path, FileAccess.READ)
		if file_read:
			var text = file_read.get_as_text()
			file_read.close()
			var json = JSON.new()
			if json.parse(text) == OK and typeof(json.data) == TYPE_DICTIONARY:
				existing_data = json.data
				
	existing_data["collectibles"] = col_data
	
	var file_write = FileAccess.open(save_path, FileAccess.WRITE)
	if file_write:
		file_write.store_string(JSON.stringify(existing_data))
		file_write.close()
