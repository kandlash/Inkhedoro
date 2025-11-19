extends CardBase

@export var damage_buff: int
@export var self_damage: int

func use(speed):
	await super.use(speed)
	make_effect()

func make_effect():
	G.player.take_damage(self_damage)
	for card: CardBase in G.grid.cards_in_grid:
		card.extra_damage = round(card.basic_damage * damage_buff/100)
