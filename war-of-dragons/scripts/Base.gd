class_name Base
extends Entity

var money
var target: Collectible = null

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	$Area3D.body_entered.connect(_on_body_entered)
	#Global.base = self
	
	entity_type = EntityType.BASE
	money = 0 #can set this for starting currency


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func collect(target):
	money += target.getvalue() #check to see if there is a collectible for the base to collect nearby
	target.queue_free() #delete object
	
func _on_body_entered(target):
	if target is Entity:
		if target.entity_type == Entity.EntityType.COLLECTIBLE:
			collect(target)
