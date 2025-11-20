extends SynergyCardBase
class_name Nail

func use(speed):
	await super.use(speed)
	for card: CardBase in active_synergy_cards:
		card.extra_damage = extra_value
	await make_damage(speed)
