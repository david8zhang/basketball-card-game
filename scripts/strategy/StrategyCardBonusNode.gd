class_name StrategyCardBonusNode
extends StrategyCardNode

enum BonusType {
  STAT,
  ROLL,
  SCORE,
  MARKER,
  TEAM_STAT,
  REM_TEAM_STAT
}

@export var bonus_type: BonusType

func process(blackboard):
	var bonus_result = StrategyCardNode.NodeResult.new(StrategyCardNode.NodeResultType.SUCCESS, self)
	blackboard.node_results.append(bonus_result)
	return StrategyCardNode.NodeResultType.SUCCESS