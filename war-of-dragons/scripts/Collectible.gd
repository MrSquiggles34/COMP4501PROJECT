class_name Collectible
extends Entity

var worth

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	entity_type = EntityType.COLLECTIBLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
