extends Control

@onready var valueLabel = $CenterContainer/VBoxContainer/ValueLabel
@onready var coinValueLabel = $CenterContainer/VBoxContainer/CoinValueLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Keep checking until Global.base is set
	while Global.base == null:
		await get_tree().process_frame
	
	print("UI connected to base: ", Global.base)
	Global.base.money_changed.connect(_on_collect)
	Global.base.coins_changed.connect(_on_coin_collect)
	
	# Update initial values
	_on_collect(Global.base.money)
	_on_coin_collect(Global.base.coins)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _on_collect(new_money):
	valueLabel.text = str(new_money)

func _on_coin_collect(new_coins):
	coinValueLabel.text = str(new_coins)
