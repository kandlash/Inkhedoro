extends Node3D
class_name EnemyBase
@onready var area_3d: Area3D = $Area3D

@export var enemy_name: String
@export_multiline var description: String

@export var hp : int = 10
var max_hp: int
@export var base_heal: int = 3
@export var random_heal_min: int = 0
@export var random_heal_max: int = 3
var final_heal = 0

@export var base_damage: int = 1
@export var random_damage_min: int = 0
@export var random_damage_max: int = 5
var final_damage: int = 0
@export var block: int = 0

@export var bleed_turns: int = 0
var bleed_damage: int = 0

var vulnarable_turns: int = 0
@export var vulnarable_damage: float = 0.5

var stun_turns: int = 0

@onready var hp_label: Label = $HP_SUB/Control/Panel/hp_label
var hp_text_template: String

@onready var ui_attack_animator: AnimationPlayer = $Attack_SUB/Control/Panel/UIAttackAnimator

@onready var attack_value_label: Label = $Attack_SUB/Control/Panel/attack_value
var attack_text_template: String

@onready var stun_texture: TextureRect = $HP_SUB/Control/Panel/StunTexture
@onready var vulnarable_texture: TextureRect = $HP_SUB/Control/Panel/VulnarableTexture
@onready var bleed_textures: Control = $HP_SUB/Control/Panel/BleedTextures

@onready var ui_turn: Sprite3D = $UI_TURN
@onready var heal_sub: SubViewport = $HEAL_SUB
@onready var attack_sub: SubViewport = $Attack_SUB
@onready var heal_value_label: Label = $HEAL_SUB/Control/Panel/heal_value

signal turn_finished
signal enemy_died

@export var attack_chance: float = 0.7 # шанс на атаку (0-1)
@export var heal_chance: float = 0.3   # шанс на лечение (0-1)

var next_action: String = "attack" # действие, которое будет выполнено следующим ходом

func _ready() -> void:
	visible = false
	max_hp = hp
	hp_text_template = hp_label.text
	attack_text_template = attack_value_label.text
	hp_label.text = hp_text_template.replace("-current_hp", str(hp)).replace("-max_hp", str(max_hp))
	attack_value_label.text = attack_text_template.replace("-value", str(base_damage))

	# В первый ход всегда атака
	next_action = "attack"
	_update_ui_turn()

func take_damage(amount: int):
	if vulnarable_turns > 0:
		vulnarable_turns -= 1
		hp -= amount + round(amount * vulnarable_damage)
		if vulnarable_turns == 0:
			vulnarable_texture.visible = false
	else:
		hp -= amount
		
	if hp <= 0:
		hp = 0
		visible = false
	hp_label.text = hp_text_template.replace("-current_hp", str(hp)).replace("-max_hp", str(max_hp))

func make_turn():
	if hp <= 0:
		await get_tree().create_timer(0.15).timeout
		emit_signal("enemy_died")
		emit_signal("turn_finished")
		return

	if stun_turns > 0:
		stun_turns -= 1
		await get_tree().create_timer(0.15).timeout
		if stun_turns == 0:
			stun_texture.visible = false
			ui_turn.visible = true
		_choose_next_action()
		emit_signal("turn_finished")
		return

	# Ходы с кровотечением
	if bleed_turns > 0:
		take_damage(bleed_damage)
		bleed_turns -= 1
		if bleed_turns == 0:
			bleed_textures.visible = false
			
	if hp <= 0:
		await get_tree().create_timer(0.15).timeout
		emit_signal("enemy_died")
		emit_signal("turn_finished")
		return
	match next_action:
		"attack":
			await _attack_player()
		"heal":
			await _heal_self()

	_choose_next_action()
	emit_signal("turn_finished")

func _choose_next_action():
	var roll = randf()
	if roll <= attack_chance:
		next_action = "attack"
	else:
		next_action = "heal"
	_update_ui_turn()

func _update_ui_turn():
	match next_action:
		"attack":
			var random_bonus = randi_range(random_damage_min, random_damage_max)
			final_damage = base_damage + random_bonus
			attack_value_label.text = attack_text_template.replace("-value", str(final_damage))
			ui_turn.texture = attack_sub.get_texture() if attack_sub.has_method("get_texture") else attack_sub.texture
		"heal":
			var random_bonus = randi_range(random_heal_min, random_heal_max)
			final_heal = base_heal + random_bonus
			heal_value_label.text = str(final_heal)
			ui_turn.texture = heal_sub.get_texture() if heal_sub.has_method("get_texture") else heal_sub.texture

func _attack_player():
	ui_attack_animator.play("attack_value_animation")
	await ui_attack_animator.animation_finished
	G.player.take_damage(final_damage)
	await G.player.damage_taked

func _heal_self():
	hp += final_heal
	if hp > max_hp:
		hp = max_hp
	hp_label.text = hp_text_template.replace("-current_hp", str(hp)).replace("-max_hp", str(max_hp))
	await get_tree().create_timer(0.1).timeout
	
func take_bleed(turns, damage):
	bleed_textures.visible = true
	bleed_turns += turns
	bleed_damage = damage

func take_stun(turns):
	stun_texture.visible = true
	stun_turns = turns
	ui_turn.visible = false

func take_vulnarable(turns):
	vulnarable_texture.visible = true
	vulnarable_turns = turns

func attack():
	pass

func buff():
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		G.current_enemy = self
		visible = true
		G.emit_signal("battle_started")
