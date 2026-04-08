class_name Base
extends Entity

var money = 0
var coins = 0
signal money_changed(new_money)
signal coins_changed(new_coins)

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
	var value = target.getValue()
	if value == null:
		value = 0.0
		
	if target is Collectible and target.collectible_type == Collectible.CollectibleType.COIN:
		coins += value
		print("Coin collected! Value: ", value, " Total coins: ", coins)
		coins_changed.emit(coins)
	else:
		money += value
		print("Egg collected! Value: ", value, " Total eggs: ", money)
		money_changed.emit(money)
		
	target.queue_free()
	
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
