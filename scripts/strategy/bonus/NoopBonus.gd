class_name NoopBonus
extends StrategyCardBonusNode

@export var show_failure := true

func _init():
	super._init()
	bonus_type = StrategyCardBonusNode.BonusType.NOOP

func process(blackboard: Blackboard):
	if show_failure:
		return super.process(blackboard)
	else:
		add_result_to_bb(StrategyCardNode.NodeResultType.FAILURE, blackboard)
		return StrategyCardNode.NodeResultType.FAILURE