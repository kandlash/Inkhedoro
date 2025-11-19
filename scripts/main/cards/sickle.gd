extends CardBase

@export var bleed_damage: int
@export var bleed_turns: int

func use(speed):
	await super.use(speed)
	await make_damage(speed)
	make_effect()

func make_effect():
	G.current_enemy.take_bleed(bleed_turns, bleed_damage)
