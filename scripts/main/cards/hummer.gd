extends SynergyCardBase

func use(speed):
	await super.use(speed)
	await make_damage(speed)
	print('fuck this sheeet - ', active_synergy_cards)
