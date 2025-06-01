class_name DiscardAction
extends StrategyCardActionNode

@export var cards_to_discard := 0

func _init():
	action_type = StrategyCardActionNode.ActionType.DISCARD