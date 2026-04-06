class_name HostileMushroom
extends Hostile

var mushroom_wander_state = preload("res://scripts/hostile_state_wander.gd").new()
@onready var HealthBar = $HealthBar3D

func _ready():
	hostile_type = HostileType.MUSHROOM
	max_health = 10
	health = max_health
	HealthBar.position = Vector3(0, 7.5, 0)
	HealthBar.scale = Vector3(5, 5, 5)

	# Enemy AI stuffs
	mushroom_wander_state.wander_radius = 24.0
	mushroom_wander_state.move_speed = 4.0
	mushroom_wander_state.pick_interval = 4.0
	mushroom_wander_state.can_pursue = false
	
	wander_state_instance = mushroom_wander_state

	change_state(mushroom_wander_state)
	
	super._ready()
