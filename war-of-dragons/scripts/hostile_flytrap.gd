class_name HostileFlytrap
extends Hostile

var flytrap_wander_state = preload("res://scripts/hostile_state_wander.gd").new()

func _ready():
	hostile_type = HostileType.FLYTRAP
	health = 25

	# Enemy AI stuffs
	flytrap_wander_state.wander_radius = 0.0
	flytrap_wander_state.move_speed = 0.0
	flytrap_wander_state.pick_interval = 1000.0

	change_state(flytrap_wander_state)
