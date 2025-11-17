extends Node2D
class_name Grid

var grid_areas: Array[Area2D]
var cards_in_grid: Array[CardBase]
func _ready() -> void:
	for i in get_children():
		if i is Sprite2D and i.get_child(0).is_in_group("grid_cells"):
			var area = i.get_child(0)
			grid_areas.append(area)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		spell_cards_on_grid()

func spell_cards_on_grid():
	for area in grid_areas:
		var card_areas = area.get_overlapping_areas()
		for card_area in card_areas:
			if card_area.is_in_group("tattoo_area"):
				var card: CardBase = card_area.get_parent()
				if cards_in_grid.has(card):
					continue
				cards_in_grid.append(card)

	for card in cards_in_grid:
		print(card.name)
		var tween = create_tween()
		var card_start_scale = card.scale
		tween.tween_property(card, "scale", card_start_scale * 1.5, 0.07).set_trans(Tween.TRANS_SPRING)
		await tween.finished
		var tween2 = create_tween()
		tween2.tween_property(card, "scale", card_start_scale, 0.07).set_trans(Tween.TRANS_SPRING)
		await tween2.finished
		
	cards_in_grid.clear()
