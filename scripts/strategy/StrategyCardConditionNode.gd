class_name StrategyCardConditionNode
extends StrategyCardNode

enum ConditionType {
  DICE_ROLL,
  STAT_CHECK,
  STAT_COMP,
  SHOT_CHECK
}

@export var condition_type: ConditionType

class ConditionResult extends StrategyCardNode.NodeResult:
  var condition_ref: StrategyCardConditionNode
  func _init(_result_type, _condition_ref):
    result_type = _result_type
    condition_ref = _condition_ref

@export var pass_child: StrategyCardNode
@export var fail_child: StrategyCardNode

func _init():
  node_type = StrategyCardNode.StrategyCardNodeType.CONDITION

func process(blackboard) -> StrategyCardNode.NodeResultType:
  var result_type = check_condition()
  if result_type == StrategyCardNode.NodeResultType.SUCCESS:
    pass_child.process(blackboard)
  else:
    fail_child.process(blackboard)
  var condition_result = ConditionResult.new(result_type, self)
  blackboard.append(condition_result)
  return result_type

func check_condition() -> StrategyCardNode.NodeResultType:
  return StrategyCardNode.NodeResultType.SUCCESS