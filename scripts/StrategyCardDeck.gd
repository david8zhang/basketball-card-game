class_name StrategyCardDeck
extends Node

@export var num_strategy_cards := 3
var cards: Array[StrategyCardConfig] = []

# Called when the node enters the scene tree for the first time.
func _ready():
  init_strategy_card_deck()

func init_strategy_card_deck():
  var all_strategy_card_configs = []
  for file_name in DirAccess.get_files_at("res://resources/strategy"):
    if file_name.get_extension() == "tres":
      var strategy_card_config = load("res://resources/strategy/" + file_name) as StrategyCardConfig
      all_strategy_card_configs.append(strategy_card_config)
  for i in range(0, num_strategy_cards):
    var random_config = all_strategy_card_configs.pick_random()
    cards.append(random_config)

func on_strategy_card_selected(selected_card_idx: int):
  var new_deck: Array[StrategyCardConfig] = []
  var idx = 0
  for c in cards:
    if idx != selected_card_idx:
      new_deck.append(c)
    idx += 1
  cards = new_deck

func get_offense_strategy_cards():
  var offense_cards = cards.filter(func(c): return c.strategy_type == StrategyCardConfig.StrategyCardType.OFFENSE)
  return offense_cards

func get_defense_strategy_cards():
  var defense_cards = cards.filter(func(c): return c.strategy_type == StrategyCardConfig.StrategyCardType.DEFENSE)
  return defense_cards