class_name DiceRollCondition
extends StrategyCardCondition

enum ComparatorType {
  LESS,
  EQUAL,
  GREATER
}

@export var dice_roll_thres := 0
@export var dice_type := 20
@export var comparator_type := ComparatorType.GREATER

class DiceRollConditionResult extends StrategyCardCondition.ConditionResult:
  var dice_roll_result := 0
  var condition_ref: DiceRollCondition

  func _init(_result_type, _dice_roll_result, _condition_ref):
    super._init(_result_type, StrategyCardCondition.StrategyCardConditionType.DICE_ROLL)
    dice_roll_result = _dice_roll_result
    condition_ref = _condition_ref

func check_condition(_off_player: BallPlayerCard, _def_player: BallPlayerCard):
  var dice_roll_result = randi_range(1, dice_type)
  var result_type
  match (comparator_type):
    ComparatorType.LESS:
      result_type = StrategyCardCondition.ConditionResultType.SUCCESS if \
        dice_roll_result <= dice_roll_thres else \
        StrategyCardCondition.ConditionResultType.FAILURE
    ComparatorType.EQUAL:
      result_type = StrategyCardCondition.ConditionResultType.SUCCESS if \
        dice_roll_result == dice_roll_thres else \
        StrategyCardCondition.ConditionResultType.FAILURE
    ComparatorType.GREATER:
      result_type = StrategyCardCondition.ConditionResultType.SUCCESS if \
        dice_roll_result >= dice_roll_thres else \
        StrategyCardCondition.ConditionResultType.FAILURE
  return DiceRollConditionResult.new(result_type, dice_roll_result, self)