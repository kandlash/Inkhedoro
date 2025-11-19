extends Sprite3D
class_name EnemyBase
@onready var area_3d: Area3D = $Area3D

@export var enemy_name: String
@export_multiline var description: String

@export var hp : int = 10
var max_hp: int
@export var base_damage: int = 1
@export var block: int = 0

@export var bleed_turns: int = 0
var bleed_damage: int = 0

var vulnarable_turns: int = 0
@export var vulnarable_damage: float = 0.0

@onready var hp_label: Label = $HP_SUB/Control/Panel/hp_label
var hp_text_template: String

@onready var ui_attack_animator: AnimationPlayer = $Attack_SUB/Control/Panel/UIAttackAnimator

@onready var attack_value_label: Label = $Attack_SUB/Control/Panel/attack_value
var attack_text_template: String

signal turn_finished
signal enemy_died
func _ready() -> void:
	max_hp = hp
	hp_text_template = hp_label.text
	attack_text_template = attack_value_label.text
	hp_label.text = hp_text_template.replace("-current_hp", str(hp)).replace("-max_hp", str(max_hp))
	attack_value_label.text = attack_text_template.replace("-value", str(base_damage))
	
func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		hp = 0
		visible = false
		emit_signal("enemy_died")
		emit_signal("turn_finished")
	hp_label.text = hp_text_template.replace("-current_hp", str(hp)).replace("-max_hp", str(max_hp))

func make_turn():
	if bleed_turns > 0:
		print('bleed!')
		take_damage(bleed_damage)
		bleed_turns -= 1
	ui_attack_animator.play("attack_value_animation")
	await ui_attack_animator.animation_finished
	G.player.take_damage(base_damage)
	await G.player.damage_taked
	emit_signal("turn_finished")
	
func take_bleed(turns, damage):
	bleed_turns += turns
	bleed_damage = damage

func attack():
	pass

func buff():
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		G.current_enemy = self
		G.emit_signal("battle_started")
