class_name StrategyCardConditionNode
extends StrategyCardNode

enum ConditionType {
	DICE_ROLL_CHECK,
	STAT_CHECK,
	STAT_COMP,
	SHOT_CHECK,
	QUARTER_CHECK
}

@export var condition_type: ConditionType
@export var pass_child: StrategyCardNode
@export var fail_child: StrategyCardNode

func _init():
	node_type = StrategyCardNode.NodeType.CONDITION

func process(blackboard: Blackboard) -> StrategyCardNode.NodeResultType:
	var result_type = check_condition(blackboard)
	var condition_result = StrategyCardNode.NodeResult.new(result_type, self)
	blackboard.node_results.append(condition_result)
	if result_type == StrategyCardNode.NodeResultType.SUCCESS:
		pass_child.process(blackboard)
	else:
		if fail_child != null:
			fail_child.process(blackboard)
	return result_type

func check_condition(_blackboard: Blackboard) -> StrategyCardNode.NodeResultType:
	return StrategyCardNode.NodeResultType.SUCCESS
