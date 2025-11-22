extends Button

func _on_pressed() -> void:
	if G.battle_hint:
		G.battle_hint.queue_free()
		G.battle_hint = null
	G.grid.spell_cards_on_grid()
	disabled = true
	await G.tbm.player_turn_started
	disabled = false
