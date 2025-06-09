class_name CPUTeam
extends Node

@onready var game = get_node("/root/Main") as Game
@onready var strategy_card_deck = $StrategyCardDeck as StrategyCardDeck
@export var strategy_card_processor_scene: PackedScene
@export var strategy_card_scene: PackedScene
@export var starting_lineup_scene: PackedScene
@export var starting_lineup_wrapper: VBoxContainer

var starting_lineup: StartingLineup
var strategy_card_processor: StrategyCardProcessor

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

func use_strategy_card(matchup_container: MatchupContainer):
  strategy_card_processor = strategy_card_processor_scene.instantiate() as StrategyCardProcessor
  add_child(strategy_card_processor)
  var rand_index = randi_range(0, strategy_card_deck.cards.size() - 1)
  var selected_strat_card_config = strategy_card_deck.cards[rand_index]
  var strategy_card = strategy_card_scene.instantiate() as StrategyCard
  strategy_card.strategy_card_config = selected_strat_card_config
  strategy_card_processor.matchup_container = matchup_container
  strategy_card_processor.off_player = matchup_container.get_off_player_card()
  strategy_card_processor.def_player = matchup_container.get_def_player_card()
  strategy_card_processor.on_strategy_card_selected.connect(strategy_card_deck.on_strategy_card_selected)
  strategy_card_processor.select_strategy_card(strategy_card, rand_index)
  strategy_card_processor.on_apply_bonus.connect(matchup_container.apply_bonuses)
