extends CharacterBody3D

@export var gravity: float = 9.8
@export var move_speed: float = 5.0

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

var outline_material: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create a ShaderMaterial and assign the outline shader
	outline_material = ShaderMaterial.new()
	outline_material.shader = load("res://shaders/entity_outline.gdshader")
	
	add_to_group("units")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	
	# navigation Movement
	if not agent.is_navigation_finished():
		var next_position: Vector3 = agent.get_next_path_position()
		var direction: Vector3 = next_position - global_position
		
		direction.y = 0
		
		if direction.length() > 0.05:
			direction = direction.normalized()
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
		else:
			velocity.x = 0
			velocity.z = 0
	else:
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()

func move_to(target: Vector3) -> void:
	agent.target_position = target

func set_selected(selected: bool) -> void:
	if selected:
		mesh.material_overlay = outline_material
	else:
		mesh.material_overlay = null
