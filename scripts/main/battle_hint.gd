extends Control

@onready var cards_hint: Control = $cards_hint
@onready var arm_hint: Control = $arm_hint
@onready var order_hint: Control = $"order_hint"
@onready var synergy_hint: Control = $synergy_hint
@onready var ink_hint: Control = $ink_hint
@onready var skip_tutor: Button = $Skip_Tutor

var arm_hint_showed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	G.get_ink_button.disabled = true
	G.battle_hint = self
	G.battle_started.connect(_show_cards_hint)
	G.card_in_grid_arrived.connect(_show_arm_hint)

func _show_cards_hint():
	skip_tutor.visible = true
	cards_hint.visible = true

func _show_arm_hint():
	if arm_hint_showed:
		return
	arm_hint_showed = true
	$arm_hint/arm_hint_timer.start()
	cards_hint.queue_free()
	arm_hint.visible = true

func _on_arm_hint_timer_timeout() -> void:
	arm_hint.queue_free()
	$order_hint/order_hint_timer.start()
	order_hint.visible = true

func _on_order_hint_timer_timeout() -> void:
	order_hint.queue_free()
	synergy_hint.visible = true
	$synergy_hint/synergy_hint_timer.start()


func _on_synergy_hint_timer_timeout() -> void:
	synergy_hint.queue_free()
	ink_hint.visible = true
	G.get_ink_button.disabled = false
	$ink_hint/ink_hint_timer.start()

func _on_ink_hint_timer_timeout() -> void:
	G.battle_hint = null
	queue_free()


func _on_skip_tutor_pressed() -> void:
	print('skip')
	G.get_ink_button.disabled = false
	queue_free()
