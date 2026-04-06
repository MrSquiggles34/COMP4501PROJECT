class_name HostileGolem
extends Hostile

@onready var anim_player = $golemAnim/AnimationPlayer
@onready var HealthBar = $HealthBar3D


var golem_wander_state = preload("res://scripts/hostile_state_wander.gd").new()
var golem_pursue_state = preload("res://scripts/hostile_state_pursue.gd").new()
var golem_attack_state = preload("res://scripts/hostile_state_attack.gd").new()

func _ready():
	hostile_type = HostileType.GOLEM
	max_health = 50
	health = max_health
	HealthBar.position = Vector3(0, 7.5, 0)
	HealthBar.scale = Vector3(5, 5, 5)

	# Enemy AI stuffs
	golem_wander_state.wander_radius = 12.0
	golem_wander_state.move_speed = 2.0
	golem_wander_state.pick_interval = 8.0
	
	golem_pursue_state.move_speed = 2.0
	golem_pursue_state.lose_distance = 8.0
	golem_pursue_state.attack_distance = 4.0
	
	golem_attack_state.attack_range = 4.0
	golem_attack_state.attack_cooldown = 4.0
	
	attack_state_instance = golem_attack_state
	pursue_state_instance = golem_pursue_state
	wander_state_instance = golem_wander_state

	change_state(golem_wander_state)
	
	super._ready()
	
func _process(delta):
	super._process(delta)
	
	if (current_state == golem_pursue_state) or (current_state == golem_wander_state and velocity.x != 0 and velocity.y != 0):
		if anim_player.current_animation != "Walk" or !anim_player.is_playing():
			anim_player.play("Walk")
			#walking is viewed to still have a bit of issues on its timing
	if current_state == golem_attack_state:	
		if anim_player.current_animation != "Attack" or !anim_player.is_playing():
			anim_player.play("Attack")
