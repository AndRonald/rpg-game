extends CharacterBody2D

signal died(exp: int)

enum State{
	IDLE,
	CHASE,
	RETURN,
	ATTACK,
	DEAD
}

@export_category("Stats")
@export var speed: int = 128
@export var attack_damage: int = 10
@export var attack_speed: float = 1.0
@export var hitpoints:int = 180
@export var aggro_range: float = 256.0
@export var attack_range: float = 70.0
@export var exp_reward: int = 600
@export_category("Related Scenes")
@export var death_packed: PackedScene

var state: State = State.IDLE
var target_player: CharacterBody2D = null
var last_attacker: CharacterBody2D

@onready var spawn_point: Vector2 = global_position
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	animation_tree.set_active(true)
	# Garante a conexão do sinal de desvio por código
	if not nav_agent.velocity_computed.is_connected(_on_navigation_agent_2d_velocity_computed):
		nav_agent.velocity_computed.connect(_on_navigation_agent_2d_velocity_computed)

func get_closest_player() -> CharacterBody2D:
	# Ajustado para "player" no singular para bater com o herói
	var players = get_tree().get_nodes_in_group("player")
	var closest: CharacterBody2D = null
	var closest_dist: float = INF
	for p in players:
		var dist = global_position.distance_to(p.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = p
	return closest

func distance_to_target() -> float:
	if target_player == null:
		return INF
	return global_position.distance_to(target_player.global_position)

func _physics_process(_delta: float) -> void:
	target_player = get_closest_player()
	if target_player == null:
		return
	if state == State.DEAD:
		return
	if state == State.ATTACK:
		return
		
	if distance_to_target() <= attack_range:
		state = State.ATTACK
		attack()
	elif distance_to_target() <= aggro_range:
		state = State.CHASE
		move()
	elif global_position.distance_to(spawn_point) > 32:
		state = State.RETURN
		move()
	elif state != State.IDLE:
		state = State.IDLE
		update_animation()

func move() -> void:
	if state == State.CHASE:
		nav_agent.target_position = target_player.global_position
	elif state == State.RETURN:
		nav_agent.target_position = spawn_point

	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var desired_velocity = global_position.direction_to(next_path_position) * speed

	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(desired_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(desired_velocity)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	# Se ele mudou para o estado de ataque no meio do frame, força a parada
	if state == State.ATTACK:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Mantida a suavização do movimento e zona morta para não patinar andando
	velocity = velocity.lerp(safe_velocity, 0.2)
	move_and_slide()

	if state == State.IDLE or state == State.CHASE or state == State.RETURN:
		if velocity.x < -10.0:
			$Sprite2D.flip_h = true
		elif velocity.x > 10.0:
			$Sprite2D.flip_h = false

	update_animation()

func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.CHASE:
			animation_playback.travel("run")
		State.RETURN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")

func attack() -> void:
	if target_player == null:
		return
		
	# CORREÇÃO CRUCIAL: Zera a velocidade na hora e aplica o movimento nulo
	velocity = Vector2.ZERO
	move_and_slide()
	
	var attack_dir: Vector2 = (target_player.global_position - global_position).normalized()
	$Sprite2D.flip_h = attack_dir.x < 0 and abs(attack_dir.x) >= abs(attack_dir.y)
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)
	update_animation()

	await get_tree().create_timer(attack_speed).timeout
	
	# Só volta para IDLE se não tiver morrido durante o ataque
	if state != State.DEAD:
		state = State.IDLE

func take_damage(damage_taken: int, attacker: CharacterBody2D) -> void:
	last_attacker = attacker
	hitpoints -= damage_taken
	if hitpoints <= 0:
		death()

func death() -> void:
	state = State.DEAD
	if last_attacker:
		last_attacker.kills += 1
		last_attacker.gain_experience(exp_reward)

	died.emit(exp_reward)

	var death_scene: Node2D = death_packed.instantiate()
	get_parent().add_child(death_scene)
	death_scene.global_position = global_position + Vector2(0.0, -32.0)

	queue_free()

func _on_hit_box_area_entered(area: Area2D) -> void:
	area.owner.take_damage(attack_damage)
