class_name StrategyCardSequenceNode
extends StrategyCardNode

@export var children: Array[StrategyCardNode]

func process(blackboard):
	var final_result_type = StrategyCardNode.NodeResultType.SUCCESS
	for c in children:
		var result_type = c.process(blackboard)
		if result_type == StrategyCardNode.NodeResultType.FAILURE:
			final_result_type = StrategyCardNode.NodeResultType.FAILURE
			break
	return final_result_type
