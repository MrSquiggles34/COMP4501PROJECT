class_name Base
extends Entity

var money
var target: Collectible = null
signal money_changed(new_money) #custom signal to set the test in 'ui'  for the player to read their money value

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	$Area3D.body_entered.connect(_on_body_entered)
	
	Global.base = self
	print("Base registered: ", self)
	print("Base position: ", global_position)
	
	entity_type = EntityType.BASE
	money = 0 #can set this for starting currency


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func collect(target):
	money += target.getValue() #check to see if there is a collectible for the base to collect nearby
	money_changed.emit(money)
	target.queue_free() #delete object
	target = null
	
func _on_body_entered(target):
	print("trying to collect")
	if target is Entity:
		print(target)
		if target.entity_type == Entity.EntityType.COLLECTIBLE:
			collect(target)
	else:
		print("could not collect")

func _enter_tree():
	Global.base = self
