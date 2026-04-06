class_name Hostile
extends DynamicEntity

@export var gravity: float = 9.8
@export var hostile_type: HostileType
@onready var health_bar_3d = $HealthBar3D

enum HostileType { MUSHROOM, SLIME, FLYTRAP, GOLEM }

var max_health
var health # is initialized as equal to max_health


# State machine
var current_state: EnemyState
var wander_state_instance: EnemyState
var pursue_state_instance: EnemyState
var attack_state_instance: EnemyState

var dragons_container: Node = null

var requires_facing_to_attack: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	entity_type = EntityType.HOSTILE
	change_state(wander_state_instance)
	health_bar_3d.init_health(max_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
		
	move_and_slide()

func change_state(new_state: EnemyState) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter(self)
	
func get_state():
	return current_state
	
func can_target_dragon(dragon: Dragon) -> bool:
	if not dragon:
		return false
	
	# Do not target burrowing dragons
	if dragon.is_untargetable():
		return false

	# Flytraps only attack flying dragons
	if hostile_type == HostileType.FLYTRAP:
		return dragon.dragon_type == Dragon.DragonType.FLY

	# All other enemies cannot attack flying dragons
	return dragon.dragon_type != Dragon.DragonType.FLY
	
func take_damage(amount: float):
	health -= amount
	
	# Update health bar here
	health_bar_3d.update_health(health)
	
	if health <= 0:
		die()
		
func die():
	play_death_effect()
	queue_free()
