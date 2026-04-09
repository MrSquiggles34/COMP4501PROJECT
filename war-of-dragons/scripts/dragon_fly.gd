class_name DragonFly
extends Dragon

@onready var anim_player = $flyDragonAnim/AnimationPlayer

func _ready():
	super._ready()
	dragon_type = DragonType.FLY
	damage = 2.0
	speed_multiplier = 1.5

func _process(delta):
	super._process(delta)
	
	match state:
		DragonState.IDLE, DragonState.MOVING, DragonState.APPROACHING:
			if anim_player.current_animation != "idle" or !anim_player.is_playing():
				anim_player.play("idle")
		DragonState.ATTACKING:
			if anim_player.current_animation != "attack" or !anim_player.is_playing():
				anim_player.play("attack")
