class_name Dragon
extends DynamicEntity

@export var gravity: float = 9.8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	entity_type = EntityType.DRAGON

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
