class_name StrategyCardTree
extends Resource

enum StrategyCardType {
  OFFENSE,
  DEFENSE
}

@export var strategy_type: StrategyCardType
@export var card_name: String
@export var card_description: String
@export var root_node: StrategyCardNode

var blackboard = []

func process():
  root_node.process(blackboard)