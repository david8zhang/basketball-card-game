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

  func _init(_result_type, _dice_roll_result):
    super._init(_result_type, StrategyCardCondition.StrategyCardConditionType.DICE_ROLL)
    dice_roll_result = _dice_roll_result

func check_condition(_off_player: BallPlayerCard, _def_player: BallPlayerCard):
  var dice_roll_result = randi_range(1, dice_type)
  match (comparator_type):
    ComparatorType.LESS:
      return StrategyCardCondition.ConditionResultType.SUCCESS if \
        dice_roll_result <= dice_roll_thres else \
        StrategyCardCondition.ConditionResultType.FAILURE
    ComparatorType.EQUAL:
      return StrategyCardCondition.ConditionResultType.SUCCESS if \
        dice_roll_result == dice_roll_thres else \
        StrategyCardCondition.ConditionResultType.FAILURE
    ComparatorType.GREATER:
      return StrategyCardCondition.ConditionResultType.SUCCESS if \
        dice_roll_result >= dice_roll_thres else \
        StrategyCardCondition.ConditionResultType.FAILURE      