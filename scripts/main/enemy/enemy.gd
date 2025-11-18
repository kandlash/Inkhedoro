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

signal turn_finished
signal enemy_died
func _ready() -> void:
	max_hp = hp
	hp_text_template = hp_label.text
	hp_label.text = hp_text_template.replace("-current_hp", str(hp)).replace("-max_hp", str(max_hp))
	
func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		hp = 0
		visible = false
		emit_signal("enemy_died")
		emit_signal("turn_finished")
	hp_label.text = hp_text_template.replace("-current_hp", str(hp)).replace("-max_hp", str(max_hp))

func make_turn():
	G.player.take_damage(base_damage)
	await G.player.damage_taked
	emit_signal("turn_finished")

func attack():
	pass

func buff():
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		G.current_enemy = self
		G.emit_signal("battle_started")
