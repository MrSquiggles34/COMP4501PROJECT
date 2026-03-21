extends Control

@onready var valueLabel = $CenterContainer/VBoxContainer/ValueLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame  # wait 1 frame
	if Global.base:
		Global.base.money_changed.connect(_on_collect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _on_collect(new_money):
	valueLabel.text = str(new_money)
