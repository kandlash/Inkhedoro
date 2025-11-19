extends Node2D
class_name Grid

@onready var right_arm: AnimatedSprite2D = $"../RightArm"
@onready var cards_hand: Hand = $"../CardsHand"
@onready var cut_self: AnimatedSprite2D = $"../CutSelf"
var cut_frame = 0
@export var cut_frame_to_effect = 4
signal turn_finished

var grid_areas: Array[Area2D]
var cards_in_grid: Array[CardBase]
var speed_mul := 1.0

func _ready() -> void:
	G.grid = self
	G.deck.connect("deck_updated", _on_deck_updated)
	for card in G.deck.unused_cards:
		card.connect("card_dropped", _on_card_dropped)
		card.connect("card_taked", _on_card_taked)
		#card.connect("card_selected", _on_card_selected)
		#card.connect("card_deselected", _on_card_deselected)
		card.connect("card_grid_exited", _on_card_grid_exited)
		card.connect("card_grid_entered", _on_card_grid_entered)
	visible = false
	cut_self.connect("frame_changed", _on_cut_frame_changed)
	
	for i in get_children():
		if i is Sprite2D and i.get_child(0).is_in_group("grid_cells"):
			var area = i.get_child(0)
			grid_areas.append(area)

func _on_deck_updated(card: CardBase):
	card.connect("card_dropped", _on_card_dropped)
	card.connect("card_taked", _on_card_taked)
	card.connect("card_selected", _on_card_selected)
	card.connect("card_deselected", _on_card_deselected)
	card.connect("card_grid_exited", _on_card_grid_exited)
	card.connect("card_grid_entered", _on_card_grid_entered)

func _on_card_dropped(card: CardBase):
	visible = false

func _on_card_taked(card: CardBase):
	if !card.on_arm:
		return
	visible = true
	
func _on_card_selected(card: CardBase):
	if card.on_arm:
		return
	visible = true

func _on_card_deselected(card: CardBase):
	if card.on_arm:
		return
	visible = false

func _on_card_grid_exited(card: CardBase):
	visible = false

func _on_card_grid_entered(card: CardBase):
	visible = true



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		spell_cards_on_grid()
	
	if cut_frame >= cut_frame_to_effect and cut_frame > 0:
		cut_frame = -1
		G.camera.shake(0.025, 0.4)


func spell_cards_on_grid():
	var start_pos = right_arm.position
	speed_mul = 1.0
	cut_frame = 0
	visible = false
	for area in grid_areas:
		var card_areas = area.get_overlapping_areas()
		for card_area in card_areas:
			if card_area.is_in_group("tattoo_area"):
				var card: CardBase = card_area.get_parent()
				if cards_in_grid.has(card):
					continue
				cards_in_grid.append(card)

	for card: CardBase in cards_in_grid:
		var speed := 1.0 / speed_mul
		
		await card.use(speed)
		
		speed_mul += 0.35 
		if G.current_enemy.hp <= 0:
			break
		
		
	right_arm.visible = false
	G.hand.drop_cards()
	cut_self.visible = true
	cut_self.play("cut")
	await cut_self.animation_finished
	cut_self.visible = false
	cards_in_grid.clear()
	right_arm.visible = true
	var tween1 = create_tween()
	
	tween1.tween_property(right_arm, "position", start_pos + Vector2(500, 0), 0.15).set_trans(Tween.TRANS_SPRING)
	await tween1.finished

	var tween2 = create_tween()
	tween2.tween_property(right_arm, "position", start_pos, 0.5).set_trans(Tween.TRANS_SPRING)
	emit_signal("turn_finished")

func _on_cut_frame_changed():
	cut_frame += 1
