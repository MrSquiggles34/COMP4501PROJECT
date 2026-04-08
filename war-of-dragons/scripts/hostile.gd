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
		
const CollectibleCoinScene = preload("res://scenes/collectible_coin.tscn")
const CollectibleEggScene = preload("res://scenes/collectible.tscn")

func die():
	play_death_effect()
	
	# Spawn collectibles
	var coin = CollectibleCoinScene.instantiate()
	var egg = CollectibleEggScene.instantiate()
	
	if coin.has_method("setValue"):
		coin.setValue(10)
	if egg.has_method("setValue"):
		egg.setValue(1)
	
	# Add to scene
	var coll_container = get_node_or_null("../../../Collectibles")
	if coll_container:
		coll_container.add_child(coin)
		coll_container.add_child(egg)
	else:
		get_parent().add_child(coin)
		get_parent().add_child(egg)
	
	# Offset them slightly so they don't overlap perfectly
	coin.global_position = global_position + Vector3(0.5, 0, 0)
	egg.global_position = global_position + Vector3(-0.5, 0, 0)
		
	queue_free()
