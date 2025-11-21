extends CardBase
class_name SynergyCardBase

@export var synergy_target_groups: Array[String]
@export var extra_value: int

var synergy_active := false
var active_synergy_cards: Array[CardBase] = []
var prev_synergy_cards: Array[CardBase] = []

var zone_state := {}  # { Area2D : bool }

func use(speed):
	super.use(speed)
	update_synergy()

func _ready() -> void:
	super._ready()
	
	for zone: Area2D in neighbor_finder.get_children():
		zone_state[zone] = false
		zone.connect("area_entered", _on_zone_entered.bind(zone))
		zone.connect("area_exited", _on_zone_exited.bind(zone))


func on_arm_effect():
	update_synergy()


func _on_zone_entered(overlap: Area2D, zone: Area2D):
	if _is_valid_target(overlap):
		zone_state[zone] = true
		_update_zone_visual(zone)
	update_synergy()


func _on_zone_exited(overlap: Area2D, zone: Area2D):
	if _is_valid_target(overlap):
		zone_state[zone] = false
		_update_zone_visual(zone)
	update_synergy()

func _update_zone_visual(zone: Area2D):
	var star := zone.get_node_or_null("SynergyMark")
	if star == null:
		return

	if zone_state[zone]:
		star.modulate = Color(1, 0.2, 0.2)  # красный индикатор
	else:
		star.modulate = Color(1, 1, 1)      # нормальный


func _is_valid_target(overlap: Area2D) -> bool:
	# 1) overlap должен быть tattoo_area
	if !overlap.is_in_group("tattoo_area"):
		return false

	# 2) его родитель должен быть карточкой
	var card := overlap.get_parent()
	if !(card is CardBase):
		return false

	# 3) нельзя триггерить на саму себя
	if card == self:
		return false

	# 4) карта должна подходить под группы синергии
	return _matches_synergy_target(card)

func update_synergy():
	if !in_grid_area:
		if synergy_active:
			for card: CardBase in active_synergy_cards:
				card.on_synergy_ui_update(false, 0)
			active_synergy_cards.clear()
			remove_synergy()
		return

	var neighbors = find_neighbor_cards()
	var new_active: Array[CardBase] = []

	for card: CardBase in active_synergy_cards:
		card.on_synergy_ui_update(false, 0)

	for card in neighbors:
		if card.in_grid_area and _matches_synergy_target(card):
			new_active.append(card)

	var had_synergy = synergy_active
	synergy_active = new_active.size() > 0
	prev_synergy_cards = active_synergy_cards.duplicate()
	active_synergy_cards = new_active

	if synergy_active and !had_synergy:
		apply_synergy()
	elif !synergy_active and had_synergy:
		remove_synergy()

	for card: CardBase in active_synergy_cards:
		card.on_synergy_ui_update(true, extra_value)


func _matches_synergy_target(card: CardBase) -> bool:
	for g in synergy_target_groups:
		if card.is_in_group(g):
			return true
	return false


func apply_synergy():
	print(self, " synergy ON with ", active_synergy_cards)

func remove_synergy():
	print("%s synergy OFF" % self)
