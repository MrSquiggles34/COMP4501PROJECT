class_name HostileSlime
extends Hostile

var slime_wander_state = preload("res://scripts/hostile_state_wander.gd").new()
var slime_pursue_state = preload("res://scripts/hostile_state_pursue.gd").new()
var slime_attack_state = preload("res://scripts/hostile_state_attack.gd").new()
@onready var HealthBar = $HealthBar3D


func _ready():
	hostile_type = HostileType.SLIME
	max_health = 20
	health = max_health
	HealthBar.position = Vector3(0, 7.5, 0)
	HealthBar.scale = Vector3(5, 5, 5)

	# Enemy AI stuffs
	slime_wander_state.wander_radius = 20.0
	slime_wander_state.move_speed = 4.0
	slime_wander_state.pick_interval = 6.0
	
	slime_pursue_state.move_speed = 4.0
	slime_pursue_state.lose_distance = 6.0
	slime_pursue_state.attack_distance = 4.0

	slime_attack_state.attack_range = 4.0
	slime_attack_state.attack_cooldown = 2.0
	
	attack_state_instance = slime_attack_state
	pursue_state_instance = slime_pursue_state
	wander_state_instance = slime_wander_state

	change_state(slime_wander_state)
	
	super._ready()
