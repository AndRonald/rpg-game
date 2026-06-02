extends Camera2D

@export var camera_zoom: float = 0.7

func _ready() -> void:
	zoom = Vector2(camera_zoom, camera_zoom)

func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("players")

	if players.is_empty():
		return

	var center := Vector2.ZERO

	for player in players:
		center += player.global_position

	center /= players.size()

	global_position = global_position.lerp(
		center,
		delta * 5.0
	)
