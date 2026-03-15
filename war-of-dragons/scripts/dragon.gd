class_name Dragon
extends DynamicEntity

@export var gravity: float = 9.8
@export var dragon_type: DragonType

enum DragonType { GROUND, FLY, BURROW }
enum DragonState { IDLE, MOVING, APPROACHING, ATTACKING, CARRYING }

var state: DragonState = DragonState.IDLE

# Attack Parameters
var attack_target: Hostile = null
var attack_distance: float = 2.0  
var collectible_target: Collectible = null
var collect_distance: float = 2.0
var bump_speed: float = 10.0
var home_base: Base

const CollectibleScene = preload("res://scenes/collectible.tscn") #collectible scene to spawn collectibles when enemies die

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	entity_type = EntityType.DRAGON
	#home_base = Global.base

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	
	#for when in an idle or moving state and a collectible body has entered into dragons range
	
	
	# Generic State Machine
	match state:
		DragonState.IDLE:
			velocity.x = 0
			velocity.z = 0
			
			#if attack_distane < 1.0:
				#_process_attack(delta)
			
		DragonState.MOVING:
			_process_movement(delta)
		
		DragonState.APPROACHING:
			# Target was destroyed

			if  attack_target and is_instance_valid(attack_target):
				print("HERE2")
							   
		
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
					set_state(DragonState.CARRYING)
			else:
				print ("HERE3")
				attack_target = null
				collectible_target = null
				set_state(DragonState.IDLE)
			
		DragonState.ATTACKING:
			print("HERE4")
			_process_attack(delta)
			
		DragonState.CARRYING:
			print("HERE5")
			_process_carrying(delta)

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
		
		if direction.length() > 0.1:
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
		return

	var direction = (attack_target.global_position - global_position).normalized()
	velocity = direction * bump_speed

	# Check if close enough to attack (right now single hit)
	if global_position.distance_to(attack_target.global_position) < attack_distance:
		var drop_position = attack_target.global_position
		
		attack_target.queue_free() #kill hostile 
		attack_target = null
		
		#spawn collectible
		var collectible = CollectibleScene.instantiate()
		var coll_container = get_node_or_null("../../../Collectibles")
		if coll_container:
			coll_container.add_child(collectible)
		else:
			get_parent().add_child(collectible)
		collectible.global_position = drop_position #drop collectible at the position of the enemy
		
		set_state(DragonState.IDLE)
		
func _process_carrying(delta):
	#this function, once a dragon is carrying a collectible will automattically start moving it back to the base
	if not home_base:
		return
	agent.target_position = home_base.global_position
	_process_movement(delta)
	
	if global_position.distance_to(home_base.global_position) < collect_distance:
		home_base.collect(collectible_target)
	
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
