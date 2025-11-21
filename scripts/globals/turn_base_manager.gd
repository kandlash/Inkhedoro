extends Node

class_name TurnBaseManager

enum GameStates {
	end_game,
	player_turn,
	enemy_turn,
	no_turn
}

var game_state
var player: Player
var enemy: EnemyBase

var hand_area: Hand
var deck: Deck

var end_game = false

var enemy_defeated = false

signal player_turn_started

func _ready() -> void:
	G.connect("battle_started", _on_battle_started)
	#G.connect("battle_finished", _on_battle_finished)
	G.grid.connect("turn_finished", _on_player_turn_finished)
	G.tbm = self
	hand_area = G.hand
	deck = G.deck
	player = G.player

func _on_battle_started():
	enemy_defeated = false
	G.current_enemy.connect("enemy_died", _on_enemy_died)
	start_player_turn()

#func _on_battle_finished():
	#clear_turn_manager()

func _on_player_turn_finished():
	end_player_turn()

func clear_turn_manager():
	print('chee')
	hand_area.drop_cards()
	game_state = GameStates.no_turn

func reset_turn_manager():
	game_state = GameStates.player_turn
	start_player_turn()

func start_player_turn():
	print('player turn')
	if G.player.hp <= 0:
		return
	if enemy_defeated:
		await get_tree().create_timer(0.5).timeout
		G.emit_signal("battle_finished")
		clear_turn_manager()
		return
	emit_signal("player_turn_started")
	hand_area.drop_cards()
	hand_area.add_cards(deck.generate_hand(3))
	
func end_player_turn():
	hand_area.drop_cards()
	game_state = GameStates.enemy_turn
	start_enemy_turn()

func start_enemy_turn():
	print('enemy turn')
	enemy = G.current_enemy
	if enemy_defeated:
		print('defeated enemy!')
		await get_tree().create_timer(0.5).timeout
		G.emit_signal("battle_finished")
		clear_turn_manager()
		return
	print('enemy making turn')	
	enemy.make_turn()
	print('turn was finished awaiting for signal')
	await enemy.turn_finished
	print('enemy finished turn')	
	end_enemy_turn()

func end_enemy_turn():
	game_state = GameStates.player_turn
	start_player_turn()

func _on_enemy_died():
	enemy_defeated = true
