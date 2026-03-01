# dynamic_entity.gd
class_name DynamicEntity
extends Entity

@export var move_speed: float = 5.0

@onready var agent: NavigationAgent3D = $NavigationAgent3D
