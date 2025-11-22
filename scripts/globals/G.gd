extends Node


var used_grids: Array[Area2D]

var card_info_ui: CardInfo

var selected_card: CardBase
var deck: Deck
var hand: Hand
var reward_hand: Hand
var camera: Camera
var grid: Grid
var right_attack: RightAttack
var right_arm
var battle_hint
var tbm: TurnBaseManager

var get_ink_button: Button

var player: Player
signal player_spawned

var current_enemy: EnemyBase
signal battle_started
signal battle_finished

signal card_in_grid_arrived


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("kill_enemy"):
		G.current_enemy.hp = 1
