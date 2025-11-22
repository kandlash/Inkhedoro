extends Node
class_name Deck

@export var deck: Dictionary[PackedScene, int]
var unused_cards: Array = []
var used_cards: Array = []
signal deck_updated

func _ready() -> void:
	G.deck = self
	generate_deck()

func generate_deck() -> void:
	unused_cards.clear()
	used_cards.clear()
	for card_scene in deck.keys():
		var count = deck[card_scene]
		for i in range(count):
			var card_instance = card_scene.instantiate()
			unused_cards.append(card_instance)
			emit_signal("deck_updated", card_instance)
	_shuffle_unused()

func add_to_deck(new_cards: Dictionary[PackedScene, int]) -> void:
	for card_scene in new_cards.keys():
		var count = new_cards[card_scene]
		for i in range(count):
			var card_instance = card_scene.instantiate()
			unused_cards.append(card_instance)
			emit_signal("deck_updated", card_instance)
	_shuffle_unused()

func _shuffle_unused() -> void:
	unused_cards.shuffle()

func generate_hand(size: int) -> Array:
	print('deck available: ', unused_cards)
	print('discard: ', used_cards)
	var hand: Array = []
	var card_index = 0
	while hand.size() < size:
		if unused_cards.is_empty():
			if used_cards.is_empty():
				break
			unused_cards = used_cards.duplicate()
			used_cards.clear()
			_shuffle_unused()

		var card = unused_cards.pop_back()
		card.selected = false
		card.z_index = card_index
		card_index += 1
		hand.append(card)
		used_cards.append(card)

	return hand
