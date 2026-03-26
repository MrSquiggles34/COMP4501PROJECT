class_name HostileGolem
extends Hostile

var golem_wander_state = preload("res://scripts/hostile_state_wander.gd").new()

func _ready():
	hostile_type = HostileType.GOLEM
	health = 50

	# Enemy AI stuffs
	golem_wander_state.wander_radius = 12.0
	golem_wander_state.move_speed = 2.0
	golem_wander_state.pick_interval = 8.0

	change_state(golem_wander_state)
