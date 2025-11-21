extends SynergyCardBase
class_name AttackSynergyCard

func use(speed):
	await super.use(speed)
	for card: CardBase in active_synergy_cards:
		card.extra_damage = extra_value
	await make_damage(speed)

func apply_synergy():
	for card: CardBase in active_synergy_cards:
		card.extra_damage = extra_value

func remove_synergy():
	for card: CardBase in prev_synergy_cards:
		card.extra_damage = 0
