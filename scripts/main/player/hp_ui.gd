extends Control

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel

@onready var player: Player
var hp_template: String
func _ready() -> void:
	hp_template = health_label.text
	await G.player_spawned
	player = G.player
	health_label.text = hp_template.replace("-current_hp", str(player.hp)).replace("-max_hp", str(player.max_hp))
	health_bar.value = player.max_hp
	health_bar.value = player.hp
	player.connect("hp_updated", _on_hp_updated)

func _on_hp_updated():
	health_label.text = hp_template.replace("-current_hp", str(player.hp)).replace("-max_hp", str(player.max_hp))
	health_bar.value = player.max_hp
	health_bar.value = player.hp
