extends EnemyState
class_name AttackState

@export var attack_range: float = 2.5
@export var attack_cooldown: float = 1.0

var target_dragon: Dragon
var attack_timer: float = 0.0

func enter(_enemy: Hostile) -> void:
	enemy = _enemy
	attack_timer = attack_cooldown

func exit() -> void:
	enemy = null
	target_dragon = null

func update(delta: float) -> void:
	if not enemy:
		return

	# Case: Target is already killed
	if not target_dragon or not is_instance_valid(target_dragon):
		switch_to_wander()
		return

	var to_target = target_dragon.global_position - enemy.global_position
	to_target.y = 0

	var dist_sq = to_target.length_squared()

	# Revert to pursue if target leaves range
	if dist_sq > attack_range * attack_range:
		switch_to_pursue()
		return

	# Stop & face the target
	enemy.velocity.x = 0
	enemy.velocity.z = 0
	
	if to_target.length() > 0.01:
		enemy.look_at(enemy.global_position + to_target.normalized(), Vector3.UP)

	# Cooldown attack
	attack_timer -= delta
	if attack_timer <= 0.0:
		perform_attack()
		attack_timer = attack_cooldown  
		

func perform_attack() -> void:
	if not target_dragon or not is_instance_valid(target_dragon):
		return

	# One hit kill
	print(enemy.name, "attacked", target_dragon.name)
	target_dragon.queue_free()
	switch_to_wander()


func switch_to_wander():
	var wander = preload("res://scripts/hostile_state_wander.gd").new()
	print(enemy.name, "switched to wander")
	enemy.change_state(wander)


func switch_to_pursue():
	var pursue = preload("res://scripts/hostile_state_pursue.gd").new()
	print(enemy.name, "switched to pursue")
	pursue.target_dragon = target_dragon
	enemy.change_state(pursue)
