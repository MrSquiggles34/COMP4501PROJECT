extends Camera3D

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position = Vector3(
		player.global_position.x,
		50.0,
		player.global_position.z
	)
	
	rotation.y = player.rotation.y
	
