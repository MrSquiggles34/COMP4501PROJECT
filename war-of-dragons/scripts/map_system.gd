extends Node

var save_path := "res://savegame.json"
var save_timer: Timer

func _ready() -> void:
	save_timer = Timer.new()
	save_timer.wait_time = 60.0
	save_timer.autostart = true
	save_timer.timeout.connect(save_collectibles_async)
	add_child(save_timer)

func _process(delta: float) -> void:
	pass

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
