extends Node3D
class_name ChoiceReward

@export var new_cards: Dictionary[PackedScene, int]        # {CardScene: any_int}
@export var select_one: bool = false

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var collect_button: Button = $CanvasLayer/Control/collect_button
@onready var hand: Hand = $CanvasLayer/Control/hand
@onready var card_amount_label: Label = $CanvasLayer/Control/card_amount_label

var spawned_cards: Array[CardBase] = []
var selected_card: CardBase = null
var active: bool = false


func _ready():
	card_amount_label.visible = false
	canvas_layer.visible = false
	collect_button.disabled = false
	collect_button.pressed.connect(_on_collect_button_pressed)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	if active:
		return

	active = true
	canvas_layer.visible = true
	G.player.arm_base.visible = false
	G.player.set_physics_process(false)
	G.player.velocity = Vector3.ZERO
	_spawn_cards()
	_setup_selection_logic()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	pass

func _spawn_cards() -> void:
	spawned_cards.clear()
	var index = 0
	for card_scene:PackedScene in new_cards.keys():
		var card:CardBase = card_scene.instantiate()
		spawned_cards.append(card)
		card.is_reward = true
		card.reward_index = index
		index += 1
		hand.add_card(card)  # Hand сам размещает их красиво
	index = 0
	var amounts = new_cards.values()
	for card: CardBase in hand.get_children():
		var number_label = card_amount_label.duplicate()
		number_label.text = "x"+str(amounts[index])
		number_label.visible = true
		hand.add_child(number_label)
		number_label.position = Vector2(
			card.position.x - number_label.size.x/2,
			-125.0
		)
		index += 1



func _setup_selection_logic() -> void:
	selected_card = null

	if select_one:
		collect_button.disabled = true
		_connect_card_selection()
	else:
		collect_button.disabled = false

func _connect_card_selection() -> void:
	for card in spawned_cards:
		if card.has_signal("card_click"):
			card.card_click.connect(_on_card_clicked.bind(card))


func _on_card_clicked(card: CardBase) -> void:
	if not select_one:
		return

	selected_card = card

	collect_button.disabled = false


func _on_collect_button_pressed() -> void:
	if select_one:
		if not selected_card:
			return 
		var values = new_cards.values()
		var keys = new_cards.keys()
		var dict: Dictionary[PackedScene, int] = {keys[selected_card.reward_index]: values[selected_card.reward_index]}
		G.deck.add_to_deck(dict)

	else:
		G.deck.add_to_deck(new_cards)
	_cleanup()

func _cleanup() -> void:
	for card in spawned_cards:
		if card.get_parent() == hand:
			hand.remove_child(card)
			card.queue_free()

	spawned_cards.clear()
	collect_button.disabled = true
	selected_card = null
	canvas_layer.visible = false
	G.player.arm_base.visible = true
	G.player.set_physics_process(true)
	active = false
	queue_free()
