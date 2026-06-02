extends Node

static func get_profile(player) -> Dictionary:

	var profile := {}
	var ratio := 0.0

	if player.damage_taken_total > 0:
		ratio = float(player.kills) / player.damage_taken_total

	if player.kills >= 20 and ratio >= 0.10:

		profile.title = "Guerreiro Ofensivo"
		profile.advice = "Você eliminou muitos inimigos e manteve boa eficiência em combate."

	elif player.damage_taken_total > 200:

		profile.title = "Sobrevivente"
		profile.advice = "Você resistiu bastante, mas precisa evitar receber tanto dano."

	elif player.level >= 5:

		profile.title = "Veterano"
		profile.advice = "Você evoluiu rapidamente durante a partida."

	else:

		profile.title = "Aventureiro"
		profile.advice = "Continue explorando diferentes estratégias."

	return profile
