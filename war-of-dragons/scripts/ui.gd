extends Control

@onready var valueLabel = $CenterContainer/VBoxContainer/ValueLabel
@onready var coinValueLabel = $CenterContainer/VBoxContainer/CoinValueLabel

@onready var purchaseMenu = $PurchaseMenu
@onready var groundButton = $PurchaseMenu/VBoxContainer/GroundButton
@onready var burrowButton = $PurchaseMenu/VBoxContainer/BurrowButton
@onready var flyButton = $PurchaseMenu/VBoxContainer/FlyButton
@onready var closeButton = $PurchaseMenu/VBoxContainer/CloseButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("UI _ready started")
	# Connect buttons immediately
	groundButton.pressed.connect(func(): _on_buy_dragon("GROUND", 1, 1))
	burrowButton.pressed.connect(func(): _on_buy_dragon("BURROW", 1, 2))
	flyButton.pressed.connect(func(): _on_buy_dragon("FLY", 1, 3))
	closeButton.pressed.connect(func(): toggle_purchase_menu(false))
	print("UI Buttons connected with lambdas")

	# Keep checking until Global.base is set for resource updates
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
	if Input.is_action_just_pressed("open_menu"):
		print("Action 'open_menu' detected")
		toggle_purchase_menu(!purchaseMenu.visible)
	
	if purchaseMenu.visible:
		_update_button_states()

func _update_button_states():
	if not Global.base: return
	
	_update_btn(groundButton, 1, 1)
	_update_btn(burrowButton, 1, 2)
	_update_btn(flyButton, 1, 3)

func _update_btn(btn: Button, egg_cost: int, coin_cost: int):
	var can_afford = Global.base.can_afford(float(egg_cost), float(coin_cost))
	btn.disabled = !can_afford
	if can_afford:
		btn.modulate = Color.WHITE
	else:
		btn.modulate = Color.RED

func toggle_purchase_menu(is_visible: bool):
	print("toggle_purchase_menu called with: ", is_visible)
	purchaseMenu.visible = is_visible
	if is_visible:
		_update_button_states()

func _on_buy_dragon(type: String, egg_cost: int, coin_cost: int):
	print("PURCHASE ATTEMPT: ", type, " Costs: Eggs=", egg_cost, " Coins=", coin_cost)
	if Global.base == null:
		print("ERROR: Global.base is null during purchase!")
		return
		
	if Global.base.can_afford(float(egg_cost), float(coin_cost)):
		print("Afforded! Deducting resources and spawning...")
		Global.base.spend(float(egg_cost), float(coin_cost))
		Global.base.spawn_dragon(type)
	else:
		print("Cannot afford: Eggs available=", Global.base.money, " Coins available=", Global.base.coins)
	
func _on_collect(new_money):
	valueLabel.text = str(new_money)

func _on_coin_collect(new_coins):
	coinValueLabel.text = str(new_coins)
