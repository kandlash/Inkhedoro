extends Button

func _on_pressed() -> void:
	G.grid.spell_cards_on_grid()
	disabled = true
	await G.tbm.player_turn_started
	disabled = false
