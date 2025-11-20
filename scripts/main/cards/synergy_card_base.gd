extends CardBase
class_name SynergyCardBase

@export var synergy_target_groups: Array[String]

var synergy_active := false
var active_synergy_cards: Array[CardBase] = []

func use(speed):
	super.use(speed)
	update_synergy()

func _ready() -> void:
	super._ready()
	for area in neighbor_finder.get_children():
		area.connect("area_entered", _on_area_entered)
		area.connect("area_exited", _on_area_exited)


func on_arm_effect():
	update_synergy()


func _on_area_entered(area: Area2D):
	update_synergy()


func _on_area_exited(area: Area2D):
	update_synergy()


func update_synergy():
	if !in_grid_area:
		if synergy_active:
			for card: CardBase in active_synergy_cards:
				card.modulate = Color(1.0, 1.0, 1.0, 1.0)
			active_synergy_cards.clear()
			remove_synergy()
		return

	var neighbors = find_neighbor_cards()
	var new_active: Array[CardBase] = []
	for card: CardBase in active_synergy_cards:
		card.modulate = Color(1.0, 1.0, 1.0, 1.0)
	for card in neighbors:
		if card.in_grid_area and _matches_synergy_target(card):
			new_active.append(card)

	var had_synergy = synergy_active
	synergy_active = new_active.size() > 0
	active_synergy_cards = new_active
	if synergy_active and !had_synergy:
		apply_synergy()
	elif !synergy_active and had_synergy:
		remove_synergy()
	
	for card: CardBase in active_synergy_cards:
		card.modulate = Color(1.0, 0.0, 0.0, 1.0)


func _matches_synergy_target(card: CardBase) -> bool:
	for g in synergy_target_groups:
		if card.is_in_group(g):
			return true
	return false


func apply_synergy():
	print(self, " synergy ON with ", active_synergy_cards)


func remove_synergy():
	print("%s synergy OFF" % self)
