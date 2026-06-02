extends Node2D

@export var end_game_screen_packed: PackedScene

var total_enemies: int
var killed_enemies: int = 0

@onready var HUD: Control = $UI/HUD

func _ready() -> void:

	var enemy_array = get_tree().get_nodes_in_group("enemiesh")

	total_enemies = enemy_array.size()

	for enemy in enemy_array:
		enemy.died.connect(enemy_died)

	var players = get_tree().get_nodes_in_group("players")

	if players.size() >= 2:

		var player1 = players[0]
		var player2 = players[1]

		player1.game_over.connect(display_end_game_screen)
		player2.game_over.connect(display_end_game_screen)

		player1.update_hp_bar.connect(HUD.update_p1_hp)
		player2.update_hp_bar.connect(HUD.update_p2_hp)

		player1.level_changed.connect(HUD.update_p1_level)
		player2.level_changed.connect(HUD.update_p2_level)

		HUD.update_p1_level(player1.level)
		HUD.update_p2_level(player2.level)


func enemy_died(_exp_reward: int) -> void:

	killed_enemies += 1

	if killed_enemies == total_enemies:
		display_end_game_screen(true)


func display_end_game_screen(victorious: bool) -> void:

	var end_game_screen_scene: Control = end_game_screen_packed.instantiate()
	end_game_screen_scene.victorious = victorious

	var scene_handler: Node = get_node("/root/SceneHandler")

	end_game_screen_scene.repeat_level.connect(scene_handler.new_game)
	end_game_screen_scene.main_menu.connect(scene_handler.load_main_menu)

	$UI.add_child(end_game_screen_scene)
