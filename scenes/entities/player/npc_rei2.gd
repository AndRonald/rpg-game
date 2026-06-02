extends Area2D

@onready var interaction_label: Label = $LabelInteracao
@onready var dialog_box: Label = $CanvasLayer/DialogBox
@onready var dialog_text: Label = $CanvasLayer/DialogText
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var player_in_area: bool = false
var is_talking: bool = false
var can_advance: bool = false
var dialogue_index: int = 0
var using_gamepad: bool = false

# VELOCIDADES DO TEXTO
var normal_speed: float = 0.04  # Velocidade padrão (40ms por letra)
var fast_speed: float = 0.005   # Velocidade acelerada (quase instantâneo)

var dialogues: Array[String] = [
	"Olhe ao seu redor... as muralhas que julgávamos impenetráveis ruíram como castelos de areia.",
	"Fomos arrogantes. Confiamos demais na nossa antiga glória e deixamos nossas fronteiras completamente desprotegidas.",
	"Os goblins e as forças invasoras sabiam exatamente onde atacar. Nossa guarda estava fraca, e o coração do reino foi exposto.",
	"Nossos soldados estão dispersos, os suprimentos queimados, e a linhagem real está a um passo de ser extinta no meio dessa fumaça.",
	"O reino nunca esteve tão vulnerável. Se você não cruzar essas pontes e revidar agora, não restará pedra sobre pedra. Vá!"
]

func _ready() -> void:
	dialog_box.visible = false
	dialog_text.visible = false
	interaction_label.visible = false
	animated_sprite_2d.play("idle")

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if using_gamepad:
			using_gamepad = false
			update_interaction_text()
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if event is InputEventJoypadMotion and abs(event.axis_value) < 0.3:
			return
		if not using_gamepad:
			using_gamepad = true
			update_interaction_text()

func _process(_delta: float) -> void:
	# O clique normal inicia ou avança para a próxima frase
	if Input.is_action_just_pressed("interact"):
		if player_in_area and not is_talking:
			start_dialogue()
		elif is_talking and can_advance:
			next_line()

func _on_body_entered(body: Node2D) -> void:
	# AJUSTADO: Agora verifica o grupo no singular "player"
	if body.is_in_group("player"):
		player_in_area = true
		update_interaction_text()
		interaction_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	# AJUSTADO: Grupo no singular "player"
	if body.is_in_group("player"):
		player_in_area = false
		interaction_label.visible = false
		if is_talking:
			end_dialogue()

func update_interaction_text() -> void:
	if using_gamepad:
		# Trocado o 'X' pelo símbolo do Quadrado
		interaction_label.text = "Pressione ' ▢ ' para interagir"
	else:
		interaction_label.text = "Pressione 'E' para interagir"
func start_dialogue() -> void:
	is_talking = true
	interaction_label.visible = false
	dialog_box.visible = true
	dialog_text.visible = true
	dialogue_index = 0
	next_line()

func next_line() -> void:
	if dialogue_index < dialogues.size():
		can_advance = false
		dialog_text.text = ""
		var text: String = dialogues[dialogue_index]
		dialogue_index += 1
		await show_text_with_effect(text)
	else:
		end_dialogue()

func show_text_with_effect(text: String) -> void:
	for letter in text:
		dialog_text.text += letter
		
		# MODIFICAÇÃO AQUI: Se o jogador estiver SEGURANDO o botão, usa a velocidade rápida
		var current_speed = normal_speed
		if Input.is_action_pressed("interact"):
			current_speed = fast_speed
			
		await get_tree().create_timer(current_speed).timeout
	
	can_advance = true

func end_dialogue() -> void:
	is_talking = false
	can_advance = false
	dialog_text.visible = false
	dialog_box.visible = false
	if player_in_area:
		interaction_label.visible = true
