class_name CPUTeam
extends Node

@onready var game = get_node("/root/Main") as Game
@onready var strategy_card_deck = $StrategyCardDeck as StrategyCardDeck
@export var strategy_card_processor_scene: PackedScene
@export var strategy_card_scene: PackedScene
@export var starting_lineup_scene: PackedScene
@export var starting_lineup_wrapper: VBoxContainer

var strategy_card: StrategyCard
var starting_lineup: StartingLineup
var strategy_card_processor: StrategyCardProcessor

func _ready():
  if starting_lineup_wrapper != null:
    starting_lineup = starting_lineup_scene.instantiate() as StartingLineup
    starting_lineup_wrapper.add_child(starting_lineup)
    var random_lineup = SceneVariables.cpu_team_bp_configs
    starting_lineup.init_cards(random_lineup)

func get_card_at_position(pos: BallPlayerStats.PlayerPosition):
  return starting_lineup.get_card_at_position(pos)

func get_starting_cards():
  return starting_lineup.starting_lineup_cards

func get_strategy_card_deck() -> Array[StrategyCardConfig]:
  return strategy_card_deck.cards

func use_strategy_card(matchup_container: MatchupContainer, rand_index: int, cards_to_pick_from):
  if strategy_card != null:
    strategy_card.queue_free()
  strategy_card_processor = strategy_card_processor_scene.instantiate() as StrategyCardProcessor
  add_child(strategy_card_processor)
  var card_to_use_config_wrapper = cards_to_pick_from[rand_index]
  strategy_card = strategy_card_scene.instantiate() as StrategyCard
  add_child(strategy_card)
  strategy_card.global_position = Vector2(1200, 240)
  strategy_card.hide()
  strategy_card.strategy_card_config = card_to_use_config_wrapper.config
  strategy_card.config_id = card_to_use_config_wrapper.config_id
  strategy_card_processor.matchup_container = matchup_container
  strategy_card_processor.off_player = matchup_container.get_off_player_card()
  strategy_card_processor.def_player = matchup_container.get_def_player_card()
  strategy_card_processor.on_strategy_card_selected.connect(strategy_card_deck.on_strategy_card_selected)
  strategy_card_processor.display_complete.connect(strategy_card_processor.process_selected_card)
  strategy_card_processor.select_strategy_card(strategy_card)
