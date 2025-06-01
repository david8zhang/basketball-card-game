class_name DiceRollCondition
extends StrategyCardConditionNode

enum ComparatorType {
  LESS,
  EQUAL,
  GREATER
}

@export var dice_roll_thres := 0
@export var comparator_type := ComparatorType.GREATER

var dice_roll_result := 0
var dice_type := 0

func _init():
  condition_type = StrategyCardConditionNode.ConditionType.DICE_ROLL_CHECK

func check_condition(blackboard: Blackboard):
  assert(!blackboard.dice_rolls.is_empty(), "Must have dice roll action!")
  var roll_dice_action_result = blackboard.dice_rolls[0] as RollDiceAction.RollDiceActionResult
  dice_roll_result = roll_dice_action_result.dice_roll_result
  dice_type = roll_dice_action_result.dice_type
  var result_type
  match (comparator_type):
    ComparatorType.LESS:
      result_type = StrategyCardNode.NodeResultType.SUCCESS if \
        dice_roll_result <= dice_roll_thres else \
        StrategyCardNode.NodeResultType.FAILURE
    ComparatorType.EQUAL:
      result_type = StrategyCardNode.NodeResultType.SUCCESS if \
        dice_roll_result == dice_roll_thres else \
        StrategyCardNode.NodeResultType.FAILURE
    ComparatorType.GREATER:
      result_type = StrategyCardNode.NodeResultType.SUCCESS if \
        dice_roll_result >= dice_roll_thres else \
        StrategyCardNode.NodeResultType.FAILURE
  return result_type