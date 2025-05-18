class_name StrategyCardCondition
extends Resource

enum StrategyCardConditionType {
  SHOT_CHECK,
  DICE_ROLL,
  STAT_COMP,
  STAT_CHECK
}

enum ConditionResultType {
  SUCCESS,
  FAILURE
}

@export var condition_type: StrategyCardConditionType

class ConditionResult:
  var result_type: ConditionResultType
  var condition_type: StrategyCardConditionType
  func _init(_result_type, _condition_type):
    result_type = _result_type
    condition_type = _condition_type

func check_condition(_off_player: BallPlayerCard, _def_player: BallPlayerCard) -> ConditionResult:
  return ConditionResult.new(ConditionResultType.SUCCESS, condition_type)