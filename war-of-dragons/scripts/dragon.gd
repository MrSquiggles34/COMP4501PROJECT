class_name Dragon
extends DynamicEntity

@export var gravity: float = 9.8
@export var dragon_type: DragonType

enum DragonType { GROUND, FLY, BURROW }
enum DragonState { IDLE, MOVING, APPROACHING, ATTACKING, CARRYING }

var state: DragonState = DragonState.IDLE

# Attack Parameters
var attack_target: Hostile = null
var attack_distance: float = 7.5
var collectible_target: Collectible = null
var collect_distance: float = 5.0
var bump_speed: float = 10.0
var home_base: Base
var damage: float
var flag: bool = false
var speed_multiplier: float = 1.0

const CollectibleScene = preload("res://scenes/collectible.tscn") #collectible scene to spawn collectibles when enemies die

# Flocking AI
var flock_group_id: int = -1
var flock_members: Array[Dragon] = []

var flock_radius: float = 5.0
var separation_radius: float = 2.0

var separation_weight: float = 3.0
var cohesion_weight: float = 0.8
var alignment_weight: float = 1.0

var flock_disable_distance: float = 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	entity_type = EntityType.DRAGON
	$AttackTimer.timeout.connect(Callable(self, "_on_attack_timer_timeout")) #cant be gotten rid of otherwise things break again
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not home_base:
		home_base = Global.base
	
	if dragon_type != DragonType.FLY:
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.y = 0
	else:
		# Flying dragons ignore gravity
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

			if  attack_target and is_instance_valid(attack_target):
				# Move towards the target
				agent.target_position = attack_target.global_position
				_process_movement(delta)
				
				# Switch to ATTACKING once close
				if global_position.distance_to(attack_target.global_position) <= attack_distance:
					set_state(DragonState.ATTACKING)
				
				
			elif collectible_target and is_instance_valid(collectible_target):
				agent.target_position = collectible_target.global_position
				_process_movement(delta)
				
				# Switch to CARRYING once close
				# also potentially handled by the on_body_entered, this method may be preferable instead
				if global_position.distance_to(collectible_target.global_position) <= collect_distance:
					if dragon_type != DragonType.BURROW:
						set_state(DragonState.CARRYING)
			else:
				attack_target = null
				collectible_target = null
				set_state(DragonState.IDLE)
			
		DragonState.ATTACKING:
			_process_attack(delta)
			
		DragonState.CARRYING:
			agent.target_position = home_base.global_position #set position to go to to be thse base, only need to calculate once
			_process_carrying(delta)

	move_and_slide()
	

func move_to(target: Vector3) -> void:
	set_state(DragonState.MOVING)
	agent.target_position = target
	
func _process_movement(delta: float):
	# navigation Movement
	if agent.is_navigation_finished():
		print("navigation finished")
		set_state(DragonState.IDLE)
		return
	else:
		var next_position: Vector3 = agent.get_next_path_position()
		var direction: Vector3 = next_position - global_position
		
		direction.y = 0  
		
		if direction.length() > 0.1:
			direction = direction.normalized()
			
			#  Only flock when far from destination
			var target_distance = global_position.distance_to(agent.target_position)
			
			if target_distance > flock_disable_distance:
				direction += calculate_flocking()
			
			# Renormalize after flocking
			if direction.length() > 0.1:
				direction = direction.normalized()
			
			var up_vector := Vector3.UP
			if abs(direction.y) > 0.999:
				up_vector = Vector3.FORWARD
				
			# rotate dragon to face movement direction
			look_at(global_position + direction, up_vector)
			
			velocity.x = direction.x * move_speed * speed_multiplier
			velocity.z = direction.z * move_speed * speed_multiplier
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
	
func carry(target: Collectible):
	if not target or not is_instance_valid(target):
		return
	collectible_target = target
	
	# Move toward the enemy first
	agent.target_position = target.global_position
	set_state(DragonState.APPROACHING)

func _process_attack(delta: float):
	if not attack_target or not is_instance_valid(attack_target):
		set_state(DragonState.IDLE)
		attack_target = null
		("stopping timer in process attack")
		$AttackTimer.stop()
		return

	var direction = (attack_target.global_position - global_position).normalized()
	velocity = direction * bump_speed
	
	if $AttackTimer.is_stopped():
		$AttackTimer.start($AttackTimer.wait_time)
		
	if $AttackTimer.get_time_left() < 0.01:
		if not attack_target or not is_instance_valid(attack_target): #was code from on_attack_timer_timeout
			$AttackTimer.stop()
			return
		
		#attack_target.health -= damages
		attack_target.take_damage(damage)
		print(attack_target.health)
		
		if attack_target.health <= 0:
			attack_target = null
			$AttackTimer.stop()
			set_state(DragonState.IDLE)
			
		
		
func _process_carrying(delta):
	_process_movement(delta)
	
	if collectible_target:
		collectible_target.global_position = global_position + Vector3(0, 1, 0)
	
		
	if agent.is_navigation_finished():
		if collectible_target:
			home_base.collect(collectible_target) #this is already done with the base on body enter
			collectible_target.queue_free()
			collectible_target = null
		set_state(DragonState.IDLE)
		

func _on_attack_timer_timeout():
	pass
	
	
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
		DragonState.CARRYING: return "CARRYING"
	return "UNKNOWN"
	
func set_flock_group(group: Array[Dragon]) -> void:
	flock_members = group

func calculate_flocking() -> Vector3:
	if flock_members.is_empty():
		return Vector3.ZERO

	var separation = Vector3.ZERO
	var cohesion = Vector3.ZERO
	var alignment = Vector3.ZERO

	var nearby_count = 0

	for dragon in flock_members:
		if dragon == self:
			continue

		if not is_instance_valid(dragon):
			continue

		var offset = dragon.global_position - global_position
		offset.y = 0

		var distance = offset.length()

		if distance > flock_radius:
			continue

		nearby_count += 1

		# Cohesion
		cohesion += dragon.global_position

		# Alignment
		alignment += dragon.velocity

		# Separation
		if distance < separation_radius and distance > 0.01:
			separation -= offset.normalized() / distance

	if nearby_count == 0:
		return Vector3.ZERO

	# Average center
	cohesion = (cohesion / nearby_count) - global_position
	cohesion.y = 0

	if cohesion.length() > 0.1:
		cohesion = cohesion.normalized()

	# Average alignment
	alignment.y = 0
	if alignment.length() > 0.1:
		alignment = alignment.normalized()

	if separation.length() > 0.1:
		separation = separation.normalized()

	return (
		separation * separation_weight +
		cohesion * cohesion_weight +
		alignment * alignment_weight
	)
	
func is_untargetable() -> bool:
	return false

func die():
	play_death_effect()
	queue_free()
