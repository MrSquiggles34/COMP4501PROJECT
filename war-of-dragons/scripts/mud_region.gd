extends Area3D

@export var speed_reduction_factor: float = 0.4

func _ready() -> void:
    self.body_entered.connect(_on_body_entered)
    self.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
    if body is Dragon:
        # Check if it's a ground or burrow dragon
        if body.dragon_type == Dragon.DragonType.GROUND or body.dragon_type == Dragon.DragonType.BURROW:
            print("Dragon entering mud: ", body.name)
            body.speed_multiplier = speed_reduction_factor

func _on_body_exited(body: Node3D) -> void:
    if body is Dragon:
        if body.dragon_type == Dragon.DragonType.GROUND or body.dragon_type == Dragon.DragonType.BURROW:
            print("Dragon exiting mud: ", body.name)
            body.speed_multiplier = 1.0
