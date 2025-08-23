class_name StrategyCardConfig
extends Resource

enum StrategyCardType {
	OFFENSE,
	DEFENSE
}

@export var strategy_type: StrategyCardType
@export var card_name: String
@export var card_description: String
@export var root_node: StrategyCardNode

var blackboard: Blackboard
var id = ""

func process(off_player: BallPlayerCard, def_player: BallPlayerCard, game_state: Dictionary = {}):
	blackboard = Blackboard.new()
	blackboard.off_player = off_player
	blackboard.def_player = def_player
	blackboard.card_config = self
	blackboard.game_state = game_state
	root_node.process(blackboard)