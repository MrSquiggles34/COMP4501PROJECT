extends Node3D

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready():
	sprite.play("smoke")
	print("effect played2")
	sprite.animation_finished.connect(_on_finished)

func _on_finished():
	queue_free()
