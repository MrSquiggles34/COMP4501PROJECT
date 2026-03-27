# dynamic_entity.gd
class_name DynamicEntity
extends Entity

@export var move_speed: float = 5.0

@onready var agent: NavigationAgent3D = $NavigationAgent3D

const SmokeEffectScene = preload("res://scenes/smoke_fx.tscn")

func play_death_effect():
	print("effect played")
	var smoke = SmokeEffectScene.instantiate()
	get_tree().current_scene.add_child(smoke)
	smoke.global_position = global_position
