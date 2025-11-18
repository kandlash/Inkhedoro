extends Node2D
class_name Grid

@onready var right_attack: AnimatedSprite2D = $"../RightAttack"
@onready var right_arm: AnimatedSprite2D = $"../RightArm"
@onready var cards_hand: Hand = $"../CardsHand"
@onready var cut_self: AnimatedSprite2D = $"../CutSelf"
var cut_frame = 0
@export var cut_frame_to_effect = 4

var grid_areas: Array[Area2D]
var cards_in_grid: Array[CardBase]
func _ready() -> void:
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

func animate_attack() -> void:
	var spr := right_attack
	var start_pos := spr.position
	var start_scale := spr.scale
	var start_rot := spr.rotation

	# старт за кадром
	spr.scale = start_scale * 0.7
	#spr.modulate.a = 0
	spr.position = start_pos + Vector2(-20, 10)
	spr.rotation = start_rot + deg_to_rad(10)

	spr.visible = true

	# Вылет
	var t = create_tween()
	t.set_parallel(true)

	t.tween_property(spr, "modulate:a", 1.0, 0.1)
	t.tween_property(spr, "scale", start_scale * 0.75, 0.1).set_trans(Tween.TRANS_BACK)
	t.tween_property(spr, "position", start_pos, 0.1).set_trans(Tween.TRANS_SINE)
	t.tween_property(spr, "rotation", start_rot, 0.1)

	await t.finished

	# Сам удар (impact snap)
	
	var t2 = create_tween()
	t2.set_parallel(true)

	t2.tween_property(spr, "scale", start_scale * 0.15, 0.04).set_trans(Tween.TRANS_SPRING)
	t2.tween_property(spr, "rotation", start_rot + deg_to_rad(randf_range(-3, 3)), 0.04)
	
	await t2.finished
	G.camera.shake(0.15, 0.1)
	G.current_enemy.take_damage(1)

	# Откат + исчезновение
	var t3 = create_tween()
	t3.set_parallel(true)

	t3.tween_property(spr, "scale", start_scale * 0.9, 0.15)
	t3.tween_property(spr, "modulate:a", 0.0, 0.15)
	t3.tween_property(spr, "position", start_pos + Vector2(10, -10), 0.15).set_trans(Tween.TRANS_SINE)

	await t3.finished

	# восстановление
	spr.position = start_pos
	spr.scale = start_scale
	spr.rotation = start_rot
	spr.visible = false

func spell_cards_on_grid():
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

	for card in cards_in_grid:
		var tween = create_tween()
		var card_start_scale = card.scale
		tween.tween_property(card, "scale", card_start_scale * 1.5, 0.07).set_trans(Tween.TRANS_SPRING)
		await tween.finished

		var tween2 = create_tween()
		tween2.tween_property(card, "scale", card_start_scale, 0.15).set_trans(Tween.TRANS_SPRING)
		await tween2.finished
		
		await get_tree().create_timer(0.15).timeout
		
		right_arm.visible = false
		cards_hand.visible = false

		right_attack.frame = randi_range(0, right_attack.sprite_frames.get_frame_count("default"))
		await animate_attack()

		cards_hand.visible = true
		right_arm.visible = true
	right_arm.visible = false
	G.hand.drop_cards()
	cut_self.visible = true
	cut_self.play("cut")
	await cut_self.animation_finished
	cut_self.visible = false
	cards_in_grid.clear()
	right_arm.visible = true

func _on_cut_frame_changed():
	cut_frame += 1
