class_name StrategyCardActionNode
extends StrategyCardNode

enum ActionType {
	DISCARD,
	DRAW,
	ROLL_DICE
}

@export var action_type: ActionType

func _init():
	node_type = StrategyCardNode.NodeType.ACTION