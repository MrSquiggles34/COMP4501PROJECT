extends Node3D

func _ready() -> void:
	# Connect the signal from the Area3D child node
	var area = $Area3D
	if area:
		area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Dragon:
		# Check if it's a ground or burrow dragon
		if body.dragon_type == Dragon.DragonType.GROUND or body.dragon_type == Dragon.DragonType.BURROW:
			print("Dragon entering water: ", body.name)
			# Make the dragon die
			if body.has_method("die"):
				# wait 2 seconds
				await get_tree().create_timer(2.0).timeout
				body.die()
			else:
				# Fallback if die() is not implemented yet
				body.play_death_effect()
				body.queue_free()
