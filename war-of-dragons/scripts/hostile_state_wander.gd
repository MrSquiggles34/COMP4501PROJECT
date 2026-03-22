# WanderState.gd
extends EnemyState
class_name WanderState

# Wander algorithm picks a random point within an enemy's spawn point radius in time intervals and walks to it
@export var wander_radius: float = 5.0       
@export var move_speed: float = 3.0           
@export var pick_interval: float = 8.0        

var home_position: Vector3                     
var target_position: Vector3
var wander_timer: Timer

func enter(_enemy: Hostile) -> void:
	enemy = _enemy
	home_position = enemy.global_position
	pick_new_target()

	# Setup a timer for pick intervals
	wander_timer = Timer.new()
	wander_timer.wait_time = pick_interval
	wander_timer.one_shot = false
	wander_timer.autostart = true
	wander_timer.timeout.connect(pick_new_target)
	enemy.add_child(wander_timer)

func exit() -> void:
	if wander_timer and wander_timer.is_inside_tree():
		wander_timer.queue_free()
	wander_timer = null
	enemy = null

func update(delta: float) -> void:
	move_towards_target(delta)

func pick_new_target() -> void:
	if not enemy:
		return

	# Pick a random point within a circle on the XZ plane around home_position
	var angle = randf() * TAU
	var radius = randf() * wander_radius
	var offset = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
	target_position = home_position + offset

	enemy.agent.target_position = target_position

func move_towards_target(delta: float) -> void:
	if not enemy or not enemy.agent:
		return

	if enemy.agent.is_navigation_finished():
		enemy.velocity.x = 0
		enemy.velocity.z = 0
		return

	# Get next path position from the NavigationAgent
	var next_pos = enemy.agent.get_next_path_position()
	var direction = next_pos - enemy.global_position
	direction.y = 0

	# Rotate the model
	if direction.length() > 0.01:
		direction = direction.normalized()
		enemy.look_at(enemy.global_position + direction, Vector3.UP)
		enemy.velocity.x = direction.x * move_speed
		enemy.velocity.z = direction.z * move_speed
	else:
		enemy.velocity.x = 0
		enemy.velocity.z = 0
