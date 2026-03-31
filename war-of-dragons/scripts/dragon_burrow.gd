class_name DragonBurrow
extends Dragon

@onready var anim_player = $burrowDragonAnim/AnimationPlayer

func _ready():
	dragon_type = DragonType.BURROW
	damage = 1.0

func _process(delta):
	super._process(delta)
	
	match state:
		DragonState.IDLE:
			if anim_player.current_animation != "idle" or !anim_player.is_playing():
				anim_player.play("idle")
		DragonState.MOVING, DragonState.APPROACHING:
			if anim_player.current_animation != "walk" or !anim_player.is_playing():
				anim_player.play("walk")
