class_name DragonGround
extends Dragon

@onready var anim_player = $groundDragonAnim/AnimationPlayer

func _ready():
	super._ready()
	dragon_type = DragonType.GROUND
	damage = 3.0
	speed_multiplier = 1.2

func _process(delta):
	super._process(delta)
	
	match state:
		DragonState.IDLE:
			if anim_player.current_animation != "Idle" or !anim_player.is_playing():
				anim_player.play("Idle")
		DragonState.MOVING, DragonState.APPROACHING, DragonState.CARRYING:
			if anim_player.current_animation != "Walk" or !anim_player.is_playing():
				anim_player.play("Walk")
		DragonState.ATTACKING:
			if anim_player.current_animation != "Bite" or !anim_player.is_playing():
				anim_player.play("Bite")
