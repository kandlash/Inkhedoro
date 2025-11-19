extends CardBase

@export var heal_value: int = 0

func use(speed):
	await super.use(speed)
	make_effect()


func make_effect():
	G.player.heal(heal_value)
