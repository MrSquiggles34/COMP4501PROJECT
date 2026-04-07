class_name DragonBurrow
extends Dragon

@onready var anim_player = $burrowDragonAnim/AnimationPlayer
@onready var normal_model = $burrowDragonAnim
var dirt_visual: Node3D

const BURROW_DIRT_SCENE = preload("res://scenes/burrow_dirt.tscn")

func _ready():
	super._ready()
	dragon_type = DragonType.BURROW
	damage = 1.0
	
	# Collide with burrow-only obstacles (Rock Region Blocker)
	collision_mask |= 2
	
	# Set two models to swap between
	dirt_visual = BURROW_DIRT_SCENE.instantiate()
	add_child(dirt_visual)
	dirt_visual.hide()

	update_burrow_visual()

func _process(delta):
	super._process(delta)
	
	update_burrow_visual()
	
	match state:
		DragonState.IDLE:
			if anim_player.current_animation != "idle" or !anim_player.is_playing():
				anim_player.play("idle")
		DragonState.ATTACKING:
			if anim_player.current_animation != "walk" or !anim_player.is_playing():
				anim_player.play("walk")
				
func update_burrow_visual():
	var burrowed = (state == DragonState.APPROACHING or state == DragonState.MOVING)

	if burrowed:
		normal_model.hide()
		dirt_visual.show()
	else:
		normal_model.show()
		dirt_visual.hide()

func is_untargetable() -> bool:
	return state == DragonState.APPROACHING
