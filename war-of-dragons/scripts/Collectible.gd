class_name Collectible
extends Entity

enum CollectibleType { EGG, COIN }
@export var collectible_type: CollectibleType = CollectibleType.EGG
@export var worth: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	entity_type = EntityType.COLLECTIBLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setValue(w):
	worth = w

func getValue():
	return worth
