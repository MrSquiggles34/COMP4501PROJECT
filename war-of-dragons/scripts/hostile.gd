class_name Hostile
extends DynamicEntity

@export var gravity: float = 9.8
@export var hostile_type: HostileType

enum HostileType { MUSHROOM, SLIME, FLYTRAP, GOLEM }

var health

# State machine
var current_state: EnemyState
var wander_state_instance: EnemyState
var pursue_state_instance: EnemyState
var attack_state_instance: EnemyState

var dragons_container: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	entity_type = EntityType.HOSTILE
	change_state(wander_state_instance)

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
