extends Marker3D

@export var move_speed: float = 15.0
@export var zoom_speed: float = 20.0
@export var min_zoom: float = 5.0
@export var max_zoom: float = 40.0

@onready var cam: Camera3D = $PlayerCamera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction := Vector3.ZERO
	
	# Movement input
	if Input.is_action_pressed("camera_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("camera_back"):
		direction += transform.basis.z
	if Input.is_action_pressed("camera_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("camera_right"):
		direction += transform.basis.x
	
	# Flatten movement so camera doesn't move vertically
	direction.y = 0
	direction = direction.normalized()
	
	global_position += direction * move_speed * delta
	
	if Input.is_action_pressed("camera_zoom_in"):
		zoom_camera(-zoom_speed * delta)
	
	if Input.is_action_pressed("camera_zoom_out"):
		zoom_camera(zoom_speed * delta)

func zoom_camera(amount: float) -> void:
	var local_pos = cam.position
	local_pos += cam.transform.basis.z * amount
	
	# Clamp zoom distance
	var distance = local_pos.length()
	distance = clamp(distance, min_zoom, max_zoom)
	local_pos = local_pos.normalized() * distance
	
	cam.position = local_pos

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(-zoom_speed * 0.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(zoom_speed * 0.1)
