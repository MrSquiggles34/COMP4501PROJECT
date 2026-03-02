class_name Hostile
extends DynamicEntity

@export var gravity: float = 9.8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	entity_type = EntityType.HOSTILE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
		
	move_and_slide()
