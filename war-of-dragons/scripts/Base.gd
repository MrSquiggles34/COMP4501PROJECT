class_name Base
extends Entity

var money = 0
var coins = 0
signal money_changed(new_money)
signal coins_changed(new_coins)
signal dragon_purchased(dragon)

const DRAGON_GROUND_SCENE = preload("res://scenes/dragon_ground.tscn")
const DRAGON_BURROW_SCENE = preload("res://scenes/dragon_burrow.tscn")
const DRAGON_FLY_SCENE = preload("res://scenes/dragon_fly.tscn")

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

func can_afford(eggs: float, c: float) -> bool:
	return money >= eggs and coins >= c

func spend(eggs: float, c: float):
	money -= eggs
	coins -= c
	money_changed.emit(money)
	coins_changed.emit(coins)

func spawn_dragon(type: String):
	var dragon_scene
	match type:
		"GROUND": dragon_scene = DRAGON_GROUND_SCENE
		"BURROW": dragon_scene = DRAGON_BURROW_SCENE
		"FLY": dragon_scene = DRAGON_FLY_SCENE
	
	var new_dragon = dragon_scene.instantiate()
	
	# Try to find the correct container
	var dragons_container = get_node_or_null("/root/GameState/Map/Entities/DynamicEntity/Dragons")
	if not dragons_container:
		# Fallback to searching in the scene tree
		var gs = get_tree().root.get_node_or_null("GameState")
		if gs:
			dragons_container = gs.get_node("Map/Entities/DynamicEntity/Dragons")
	
	if dragons_container:
		dragons_container.add_child(new_dragon)
	else:
		# Ultimate fallback
		get_tree().current_scene.add_child(new_dragon)
		
	# Offset slightly to avoid exact overlap if buying many
	var offset = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
	new_dragon.global_position = Vector3(-9, 2, 45) + offset
	dragon_purchased.emit(new_dragon)
	print("Spawned ", type, " dragon at ", new_dragon.global_position)

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
