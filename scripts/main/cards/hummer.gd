extends CardBase


func use(speed):
	await super.use(speed)
	await make_damage(speed)
	

func on_arm_effect():
	synerge()

func synerge():
	var neigbors = find_neighbor_cards()
	for card: CardBase in neigbors:
		if card is Nail and card.on_arm:
			card.scale *= 2

func _on_area_2d_area_entered(area: Area2D) -> void:
	synerge()
