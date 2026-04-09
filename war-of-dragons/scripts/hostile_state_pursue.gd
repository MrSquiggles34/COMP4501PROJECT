extends EnemyState
class_name PursueState

@export var move_speed: float = 4.0
@export var lose_distance: float = 12.0   
@export var attack_distance: float = 2.5  

@export var vision_distance: float = 14.0
@export var vision_angle: float = 60.0

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
	
	# Case: Burrow Dragon is underground
	if not enemy.can_target_dragon(target_dragon):
		switch_to_wander()
		return

	var better_target = find_closest_dragon_in_cone()
	if better_target:
		target_dragon = better_target

	var to_target = target_dragon.global_position - enemy.global_position
	to_target.y = 0

	# Switch back to wander if dragon 'escapes'
	var dist_sq = to_target.length_squared()
	if dist_sq > lose_distance * lose_distance:
		switch_to_wander()
		return

	# Switch to attack mode using preconfigured attack state
	if dist_sq <= enemy.pursue_state_instance.attack_distance * enemy.pursue_state_instance.attack_distance:
		print(enemy.name, "switched to attack")
		enemy.attack_state_instance.target_dragon = target_dragon
		enemy.change_state(enemy.attack_state_instance)
		return

	# Pursue
	enemy.agent.target_position = target_dragon.global_position
	
	move_towards_target()

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
	enemy.change_state(enemy.wander_state_instance)
	

func find_closest_dragon_in_cone() -> Dragon:
	var dragons = enemy.get_tree().get_nodes_in_group("dragons")

	var closest_dragon: Dragon = null
	var closest_dist_sq: float = INF

	var forward = -enemy.transform.basis.z.normalized()

	for dragon in dragons:
		if not is_instance_valid(dragon):
			continue
		if not enemy.can_target_dragon(dragon):
			continue

		var to_dragon = dragon.global_position - enemy.global_position
		to_dragon.y = 0

		var dist_sq = to_dragon.length_squared()

		# Distance check 
		if dist_sq > vision_distance * vision_distance:
			continue

		# Angle check
		var dir = to_dragon.normalized()
		var angle_deg = rad_to_deg(forward.angle_to(dir))

		if angle_deg > vision_angle:
			continue

		# Keep closest
		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			closest_dragon = dragon

	return closest_dragon
