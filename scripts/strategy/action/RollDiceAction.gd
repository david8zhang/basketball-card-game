class_name RollDiceAction
extends StrategyCardActionNode

@export var dice_type := 20
var dice_roll_result := 0

func _init():
  super._init()
  action_type = StrategyCardActionNode.ActionType.ROLL_DICE

func process(blackboard: Blackboard):
  dice_roll_result = randi_range(19, dice_type)
  var node_result = StrategyCardNode.NodeResult.new(StrategyCardNode.NodeResultType.SUCCESS, self)
  blackboard.node_results.append(node_result)
  return StrategyCardNode.NodeResultType.SUCCESS