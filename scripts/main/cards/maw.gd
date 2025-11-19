extends CardBase

@export var stun_turns: int = 1

func use(speed):
	await super.use(speed)
	await make_damage(speed)
	make_effect()

func make_effect():
	G.current_enemy.take_stun(stun_turns)
