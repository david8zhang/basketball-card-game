class_name StrategyCardBonusNode
extends StrategyCardNode

class BonusResult extends StrategyCardNode.NodeResult:
	func _init():
		result_type = StrategyCardNode.NodeResultType.SUCCESS

func process(blackboard):
	var bonus_result = BonusResult.new()
	blackboard.append(bonus_result)
	return StrategyCardNode.NodeResultType.SUCCESS