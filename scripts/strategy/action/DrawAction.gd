class_name DrawAction
extends StrategyCardActionNode

@export var cards_to_draw := 0

func _init():
	action_type = StrategyCardActionNode.ActionType.DRAW