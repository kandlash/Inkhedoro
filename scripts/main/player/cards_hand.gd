extends Panel
class_name Hand

@export var card_spacing := 80
@export var max_card_angle := 3
@export var base_y_offset := 150
@export var smooth_appearance := true
@export var tween_time := 0.25

func _ready() -> void:
	G.hand = self
	add_cards(G.deck.generate_hand(3))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		add_cards(G.deck.generate_hand(3))
	if Input.is_action_just_pressed("ui_down"):
		drop_cards()

func add_card(card):
	card.visible = true
	if card.get_parent() == self:
		_update_card_layout()
		return
	add_child(card)
	card.connect("card_dropped", _on_card_dropped)
	_update_card_layout()

func _on_card_dropped(_card):
	_update_card_layout()

func add_cards(cards):
	for card in cards:
		add_card(card)

func drop_cards():
	G.used_grids.clear()
	var cards = get_children()
	for card in cards:
		card.on_arm = false
		if card.is_connected("card_dropped", _on_card_dropped):
			card.disconnect("card_dropped", _on_card_dropped)
		remove_child(card)

func _update_card_layout() -> void:
	var cards_to_update: Array[CardBase]
	for card in get_children():
		if card.on_arm:
			continue
		cards_to_update.append(card)

	var count := cards_to_update.size()
	if count == 0:
		return
		
	var center_x = size.x / 2
	var base_y = size.y - base_y_offset
	var card_size = cards_to_update[0].scale

	if count == 1:
		var card = cards_to_update[0]
		_set_card_transform(card, Vector2(center_x - card_size.x / 2, base_y), 0.0, 0)
		return

	var total_width = (count - 1) * card_spacing + card_size.x
	var start_x = center_x - total_width / 2
	var angle_step = (max_card_angle * 2.0) / (count - 1)
	var start_angle = max_card_angle

	for i in range(count):
		var card = cards_to_update[i]
		var rot_deg = start_angle - i * angle_step
		var x = start_x + i * card_spacing
		var y = base_y - abs(rot_deg) * 1.2
		_set_card_transform(card, Vector2(x, y), rot_deg, i)

func _set_card_transform(card: CanvasItem, target_pos: Vector2, target_rot: float, index: int) -> void:
	if !card:
		return
	card.z_index = index
	if smooth_appearance:
		var tween = create_tween()
		tween.tween_property(card, "position", target_pos, tween_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "rotation_degrees", target_rot, tween_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_callback(Callable.create(self, "update_card").bind(card))
	else:	
		card.position = target_pos
		card.rotation_degrees = target_rot
