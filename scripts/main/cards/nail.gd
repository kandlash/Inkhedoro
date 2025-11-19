extends CardBase

func use(speed):
	await super.use(speed)
	await make_damage(speed)
