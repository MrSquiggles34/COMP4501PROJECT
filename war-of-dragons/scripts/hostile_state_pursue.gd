extends EnemyState
class_name PursueState

@export var move_speed: float = 4.0
@export var lose_distance: float = 12.0   
@export var attack_distance: float = 2.5  

var target_dragon: Dragon

func enter(_enemy: Hostile) -> void:
	enemy = _enemy

func exit() -> void:
	enemy = null
	target_dragon = null

func update(delta: float) -> void:
	#  Return if not a hostile or target is not a dragon
	if not enemy:
		return

	if not target_dragon or not is_instance_valid(target_dragon):
		switch_to_wander()
		return

	var to_target = target_dragon.global_position - enemy.global_position
	to_target.y = 0

	# Switch back to wander if dragon 'escapes'
	var dist_sq = to_target.length_squared()
	if dist_sq > lose_distance * lose_distance:
		switch_to_wander()
		return

	# Pursue
	enemy.agent.target_position = target_dragon.global_position
	move_towards_target()

	# TO DO: SWITCH TO ATTACK MODE
	# if dist_sq <= attack_distance * attack_distance:
	#     enemy.change_state(preload("res://scripts/hostile_state_attack.gd").new())

func move_towards_target() -> void:
	if not enemy.agent:
		return

	if enemy.agent.is_navigation_finished():
		enemy.velocity.x = 0
		enemy.velocity.z = 0
		return

	var next_pos = enemy.agent.get_next_path_position()
	var direction = next_pos - enemy.global_position
	direction.y = 0

	if direction.length() > 0.01:
		direction = direction.normalized()

		# Rotate toward movement
		enemy.look_at(enemy.global_position + direction, Vector3.UP)

		enemy.velocity.x = direction.x * move_speed
		enemy.velocity.z = direction.z * move_speed
	else:
		enemy.velocity.x = 0
		enemy.velocity.z = 0

func switch_to_wander() -> void:
	var wander_state = preload("res://scripts/hostile_state_wander.gd").new()
	enemy.change_state(wander_state)
