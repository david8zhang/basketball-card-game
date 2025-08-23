class_name QuarterCheckCondition
extends StrategyCardConditionNode

enum ComparatorType {
	LESS,
	EQUAL,
	GREATER
}

@export var quarter_threshold := 1
@export var comparator_type := ComparatorType.EQUAL

func _init():
	super._init()
	condition_type = StrategyCardConditionNode.ConditionType.QUARTER_CHECK

func check_condition(blackboard: Blackboard) -> StrategyCardNode.NodeResultType:
	var current_quarter = get_current_quarter(blackboard)
	var result_type: StrategyCardNode.NodeResultType
	
	match comparator_type:
		ComparatorType.LESS:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if \
			current_quarter < quarter_threshold else \
			StrategyCardNode.NodeResultType.FAILURE
		ComparatorType.EQUAL:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if \
			current_quarter == quarter_threshold else \
			StrategyCardNode.NodeResultType.FAILURE
		ComparatorType.GREATER:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if \
			current_quarter > quarter_threshold else \
			StrategyCardNode.NodeResultType.FAILURE
	
	return result_type

func get_current_quarter(blackboard: Blackboard) -> int:
	# Get the current quarter from the blackboard game state
	if blackboard.game_state.has("current_quarter"):
		return blackboard.game_state["current_quarter"]
	
	# Default fallback - this shouldn't happen in normal gameplay
	print("Warning: Could not determine current quarter from blackboard, defaulting to 1")
	return 1
