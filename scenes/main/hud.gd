extends Control

func _ready() -> void:
	pass


# PLAYER 1

func update_p1_hp(new_value: float) -> void:
	%HitpointsBar.value = new_value


func update_p1_level(level: int) -> void:
	$LevelIndicator/CurrentLevel.text = str(level)


# PLAYER 2

func update_p2_hp(new_value: float) -> void:
	$Hitpoints2/HitpointsBar.value = new_value


func update_p2_level(level: int) -> void:
	$LevelIndicator2/CurrentLevel.text = str(level)
