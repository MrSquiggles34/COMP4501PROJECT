class_name CollectibleCoin
extends Collectible


@export var rotation_speed: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	collectible_type = CollectibleType.COIN


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(rotation_speed * delta)
