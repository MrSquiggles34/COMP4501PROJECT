class_name HostileFlytrap
extends Hostile

@onready var anim_player = $flyTrapAnim/AnimationPlayer

var flytrap_wander_state = preload("res://scripts/hostile_state_wander.gd").new()
var flytrap_pursue_state = preload("res://scripts/hostile_state_pursue.gd").new()
var flytrap_attack_state = preload("res://scripts/hostile_state_attack.gd").new()

func _ready():
	hostile_type = HostileType.FLYTRAP
	health = 25
	requires_facing_to_attack = false
	

	# Enemy AI stuffs
	flytrap_wander_state.wander_radius = 0.0
	flytrap_wander_state.move_speed = 0.0
	flytrap_wander_state.pick_interval = 1000.0
	flytrap_wander_state.vision_angle = 350.0
	
	flytrap_pursue_state.move_speed = 0.0
	flytrap_pursue_state.lose_distance = 6.0
	flytrap_pursue_state.attack_distance = 8.0
	flytrap_pursue_state.vision_angle = 350.0

	flytrap_attack_state.attack_range = 8.0
	flytrap_attack_state.attack_cooldown = 2.0

	attack_state_instance = flytrap_attack_state
	pursue_state_instance = flytrap_pursue_state
	wander_state_instance = flytrap_wander_state

	change_state(flytrap_wander_state)
	
	super._ready()
	
func _process(delta):
	super._process(delta)
	
	if current_state == flytrap_attack_state:	
		if anim_player.current_animation != "Attack" or !anim_player.is_playing():
			anim_player.play("Attack")
	else:
		if anim_player.current_animation != "Idle" or !anim_player.is_playing():
			anim_player.play("Idle")
