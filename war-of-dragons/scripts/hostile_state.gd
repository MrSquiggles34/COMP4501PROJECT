extends Node
class_name EnemyState

# Reference to the Hostile enemy
var enemy: Hostile

func enter(_enemy: Hostile) -> void:
	enemy = _enemy

func exit() -> void:
	enemy = null

func update(delta: float) -> void:
	pass
