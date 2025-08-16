class_name StrategyCardDeck
extends Node

@export var num_strategy_cards := 3
@export var override_configs = []
var cards_in_play: Array[StrategyCardConfigWrapper] = []

class StrategyCardConfigWrapper:
	var config_id := 0
	var config: StrategyCardConfig

	func _init(_config: StrategyCardConfig, _config_id: int):
		config = _config
		config_id = _config_id

func init_strategy_card_deck(strategy_card_configs):
	var idx = 0
	for config in strategy_card_configs:
		var config_wrapper = StrategyCardConfigWrapper.new(config, idx)
		cards_in_play.append(config_wrapper)
		idx += 1

func on_strategy_card_selected(selected_card_id: int):
	cards_in_play = cards_in_play.filter(func (c): return c.config_id != selected_card_id)

func get_offense_strategy_cards():
	var offense_cards = cards_in_play.filter(func(c): return c.config.strategy_type == StrategyCardConfig.StrategyCardType.OFFENSE)
	return offense_cards

func get_defense_strategy_cards():
	var defense_cards = cards_in_play.filter(func(c): return c.config.strategy_type == StrategyCardConfig.StrategyCardType.DEFENSE)
	return defense_cards

func reset_strategy_card_deck(strategy_card_configs):
	cards_in_play = []
	init_strategy_card_deck(strategy_card_configs)
