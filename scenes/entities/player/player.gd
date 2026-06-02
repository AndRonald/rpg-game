extends CharacterBody2D

signal game_over(victorious: bool)
signal update_hp_bar(hp_bar_value: int)
signal level_changed(level: int)
signal experience_changed(experience: int)

enum State {
	IDLE,
	RUN,
	ATTACK,
	DEAD
}

@export_category("Stats")
@export var speed: int = 400
@export var attack_damage: int = 60
@export var hitpoints: int = 150
@export_category("Player")
@export var device_id: int = 0  # 0 = Player 1, 1 = Player 2

var last_dir: Vector2 = Vector2.RIGHT
var state: State = State.IDLE
var move_direction: Vector2 = Vector2(0,0)
var attack_speed: float
var hitpoints_max: int
var level: int = 1
var experience: int = 0
var kills: int = 0
var damage_taken_total: int = 0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func _ready() -> void:
	hitpoints_max = hitpoints
	add_to_group("players")
	animation_tree.set_active(true)
	calculate_stats()
	update_hp_bar.emit(100.0)
	level_changed.emit(level)
	$HitBox.monitoring = false  # ← desativa monitoramento, shape continua existindo


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("p%s_attack" % device_id):
		attack()

func _physics_process(delta: float) -> void:
	if not state == State.ATTACK:
		movement_loop()

func calculate_stats() -> void:
	attack_speed = Equations.calculate_attack_speed()
	var time_factor: float = Equations.BASE_ATTACK_SPEED / attack_speed
	animation_tree.set("parameters/attack/TimeScale/scale", time_factor)

func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("p%s_right" % device_id)) - int(Input.is_action_pressed("p%s_left" % device_id))
	move_direction.y = int(Input.is_action_pressed("p%s_down" % device_id)) - int(Input.is_action_pressed("p%s_up" % device_id))

	if move_direction != Vector2.ZERO:
		last_dir = move_direction.normalized()

	var motion: Vector2 = move_direction.normalized() * speed
	set_velocity(motion)
	move_and_slide()

	if state == State.IDLE or state == State.RUN:
		if move_direction.x < -0.1:
			$Sprite2D.flip_h = true
		elif move_direction.x > 0.1:
			$Sprite2D.flip_h = false

	if motion != Vector2.ZERO and state == State.IDLE:
		state = State.RUN
		update_animation()
	elif motion == Vector2.ZERO and state == State.RUN:
		state = State.IDLE
		update_animation()

func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")


func attack() -> void:
	if state == State.ATTACK:
		return
	
	state = State.ATTACK
	
	var attack_dir: Vector2 = Vector2(
		Input.get_axis("p%s_left" % device_id, "p%s_right" % device_id),
		Input.get_axis("p%s_up" % device_id, "p%s_down" % device_id)
	)
	
	if attack_dir == Vector2.ZERO:
		attack_dir = last_dir
		
	$Sprite2D.flip_h = attack_dir.x < 0 and abs(attack_dir.x) >= abs(attack_dir.y)
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)
	update_animation()
	
	$HitBox.monitoring = true   # ativa só durante o ataque
	
	await get_tree().create_timer(attack_speed).timeout
	
	$HitBox.monitoring = false  # desativa ao terminar
	
	state = State.IDLE


func take_damage(damage_taken: int) -> void:
	damage_taken_total += damage_taken
	hitpoints -= damage_taken
	
	update_hp_bar.emit((hitpoints * 100.0) / hitpoints_max)
	
	if hitpoints <= 0:
		death()

func death() -> void:
	game_over.emit(false)

func _on_hit_box_area_entered(area: Area2D) -> void:
	
	if area.owner.has_method("take_damage"):
		area.owner.take_damage(
			attack_damage,
			self
		)

func gain_experience(exp_gain: int) -> void:
	if level == LevelData.MAX_LEVEL:
		return
		
		
	var new_experience = experience + exp_gain
	
	if new_experience >= LevelData.LEVEL_THRESHOLDS[level - 1]:
			level_up(new_experience)
	else:
		experience = new_experience
		experience_changed.emit(experience)


func level_up(new_experience: int) -> void:

	new_experience -= LevelData.LEVEL_THRESHOLDS[level - 1]

	level += 1
	experience = new_experience

	calculate_stats()

	level_changed.emit(level)
