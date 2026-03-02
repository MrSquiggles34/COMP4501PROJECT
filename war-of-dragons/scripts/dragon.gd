class_name Dragon
extends DynamicEntity

@export var gravity: float = 9.8

enum DragonState { IDLE, MOVING, APPROACHING, ATTACKING }
var state: DragonState = DragonState.IDLE

# Attack Parameters
var attack_target: Hostile = null
var attack_distance: float = 2.0  
var bump_speed: float = 10.0

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
	
	# Generic State Machine
	match state:
		DragonState.IDLE:
			velocity.x = 0
			velocity.z = 0
			
		DragonState.MOVING:
			_process_movement(delta)
		
		DragonState.APPROACHING:
			# Target was destroyed
			if not attack_target or not is_instance_valid(attack_target):
				attack_target = null
				set_state(DragonState.IDLE)
			else:
				# Move towards the target
				agent.target_position = attack_target.global_position
				_process_movement(delta)
				
				# Switch to ATTACKING once close
				if global_position.distance_to(attack_target.global_position) <= attack_distance:
					set_state(DragonState.ATTACKING)
			
		DragonState.ATTACKING:
			_process_attack(delta)

	move_and_slide()
	

func move_to(target: Vector3) -> void:
	set_state(DragonState.MOVING)
	agent.target_position = target
	
func _process_movement(delta: float):
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
			set_state(DragonState.IDLE)

func attack(target: Hostile):
	if not target or not is_instance_valid(target):
		return
	attack_target = target
	
	# Move toward the enemy first
	agent.target_position = target.global_position
	set_state(DragonState.APPROACHING)

func _process_attack(delta: float):
	if not attack_target or not is_instance_valid(attack_target):
		set_state(DragonState.IDLE)
		attack_target = null
		return

	var direction = (attack_target.global_position - global_position).normalized()
	velocity = direction * bump_speed

	# Check if close enough to attack (right now single hit)
	if global_position.distance_to(attack_target.global_position) < attack_distance:
		attack_target.queue_free()  
		attack_target = null
		set_state(DragonState.IDLE)
		
		
# Change the state of the dragon & print
func set_state(new_state: DragonState) -> void:
	if state == new_state:
		return
	
	print(name, " state change: ", state_to_string(state), " -> ", state_to_string(new_state))
	state = new_state

func state_to_string(s: DragonState) -> String:
	match s:
		DragonState.IDLE: return "IDLE"
		DragonState.MOVING: return "MOVING"
		DragonState.APPROACHING: return "APPROACHING"
		DragonState.ATTACKING: return "ATTACKING"
	return "UNKNOWN"
