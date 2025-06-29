class_name StrategyCardDeck
extends Node

@export var num_strategy_cards := 3
var cards: Array[StrategyCardConfigWrapper] = []

class StrategyCardConfigWrapper:
  var config_id := 0
  var config: StrategyCardConfig

  func _init(_config: StrategyCardConfig, _config_id: int):
    config = _config
    config_id = _config_id

# Called when the node enters the scene tree for the first time.
func _ready():
  init_strategy_card_deck()

func init_strategy_card_deck():
  var all_strategy_card_configs = [load("res://resources/strategy/ChaseDownBlock.tres")]
  # for file_name in DirAccess.get_files_at("res://resources/strategy"):
  #   if file_name.get_extension() == "tres":
  #     var strategy_card_config = load("res://resources/strategy/" + file_name) as StrategyCardConfig
  #     all_strategy_card_configs.append(strategy_card_config)
  for i in range(0, num_strategy_cards):
    # var random_config = all_strategy_card_configs.pick_random()
    var random_config = all_strategy_card_configs[i % all_strategy_card_configs.size()]
    var config_wrapper = StrategyCardConfigWrapper.new(random_config, i)
    cards.append(config_wrapper)

func on_strategy_card_selected(selected_card_id: int):
  cards = cards.filter(func (c): return c.config_id != selected_card_id)

func get_offense_strategy_cards():
  var offense_cards = cards.filter(func(c): return c.config.strategy_type == StrategyCardConfig.StrategyCardType.OFFENSE)
  return offense_cards

func get_defense_strategy_cards():
  var defense_cards = cards.filter(func(c): return c.config.strategy_type == StrategyCardConfig.StrategyCardType.DEFENSE)
  return defense_cards