extends CardBase
class_name Nail

func use(speed):
	await super.use(speed)
	await make_damage(speed)
