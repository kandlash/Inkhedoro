extends CardBase

@export var vulnarable_turns: int = 2

func use(speed):
	await super.use(speed)
	await make_damage(speed)
	make_effect()

func make_effect():
	G.current_enemy.take_vulnarable(vulnarable_turns)
