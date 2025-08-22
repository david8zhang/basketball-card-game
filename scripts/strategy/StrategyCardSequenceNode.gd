class_name StrategyCardSequenceNode
extends StrategyCardNode

@export var children: Array[StrategyCardNode]

func process(blackboard):
	for c in children:
		c.process(blackboard)
	return StrategyCardNode.NodeResultType.SUCCESS
