class_name RollDiceAction
extends StrategyCardActionNode

@export var dice_type := 20
var dice_roll_result := 0

func _init():
  action_type = StrategyCardActionNode.ActionType.ROLL_DICE

class RollDiceActionResult:
  var dice_roll_result := 0
  var dice_type := 0
  func _init(_dice_roll_result, _dice_type):
    dice_roll_result = _dice_roll_result
    dice_type = _dice_type

func process(blackboard: Blackboard):
  dice_roll_result = randi_range(1, dice_type)
  blackboard.dice_rolls.append(RollDiceActionResult.new(dice_roll_result, dice_type))
  return StrategyCardNode.NodeResultType.SUCCESS