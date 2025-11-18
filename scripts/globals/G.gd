extends Node


var used_grids: Array[Area2D]

var selected_card: CardBase
var deck: Deck
var hand: Hand
var camera: Camera
var grid: Grid

var tbm: TurnBaseManager

var player: Player
signal player_spawned

var current_enemy: EnemyBase
signal battle_started
signal battle_finished
