class_name HostileSlime
extends Hostile

var slime_wander_state = preload("res://scripts/hostile_state_wander.gd").new()

func _ready():
	hostile_type = HostileType.SLIME
	health = 20;

	# Enemy AI stuffs
	slime_wander_state.wander_radius = 20.0
	slime_wander_state.move_speed = 4.0
	slime_wander_state.pick_interval = 6.0

	change_state(slime_wander_state)
