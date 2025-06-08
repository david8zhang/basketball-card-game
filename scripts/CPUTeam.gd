class_name CPUTeam
extends Node

@onready var game = get_node("/root/Main") as Game
@onready var strategy_card_deck = $StrategyCardDeck as StrategyCardDeck
@export var starting_lineup_scene: PackedScene
@export var starting_lineup_wrapper: VBoxContainer

var starting_lineup: StartingLineup

func _ready():
  if starting_lineup_wrapper != null:
    starting_lineup = starting_lineup_scene.instantiate() as StartingLineup
    starting_lineup_wrapper.add_child(starting_lineup)
    var random_lineup = game.assemble_random_lineup()
    starting_lineup.init_cards(random_lineup)

func get_card_at_position(pos: BallPlayerStats.PlayerPosition):
  return starting_lineup.get_card_at_position(pos)

func get_starting_cards():
  return starting_lineup.starting_lineup_cards

func get_strategy_card_deck() -> Array[StrategyCardConfig]:
  return strategy_card_deck.cards