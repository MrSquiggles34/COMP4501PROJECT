extends Marker3D

@export var move_speed: float = 15.0
@export var zoom_sensitivity: float = 20.0 
@export var zoom_in_bound: float = 5.0
@export var zoom_out_bound: float = 40.0

@onready var starting_position: Vector3 = global_position

func _process(delta: float) -> void:
	var direction := Vector3.ZERO
	
	# Panning logic
	if Input.is_action_pressed("camera_forward"): 
		direction -= transform.basis.z
	if Input.is_action_pressed("camera_back"):    
		direction += transform.basis.z
	if Input.is_action_pressed("camera_left"):    
		direction -= transform.basis.x
	if Input.is_action_pressed("camera_right"):   
		direction += transform.basis.x
	
	# Keep movement on the horizontal plane
	direction.y = 0
	
	if direction != Vector3.ZERO:
		global_position += direction.normalized() * move_speed * delta
		starting_position += direction.normalized() * move_speed * delta

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		zoom(-zoom_sensitivity)
	elif event.is_action_pressed("camera_zoom_out"):
		zoom(zoom_sensitivity)

func zoom(amount: float) -> void:
	var move_vec = transform.basis.z * amount * get_process_delta_time()
	var new_pos = global_position + move_vec
	var offset_from_start = (new_pos - starting_position).dot(transform.basis.z)
	
	offset_from_start = clamp(offset_from_start, -zoom_in_bound, zoom_out_bound)
	
	global_position = starting_position + (transform.basis.z * offset_from_start)
