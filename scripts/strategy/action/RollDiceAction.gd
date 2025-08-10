class_name RollDiceAction
extends StrategyCardActionNode

@export var dice_type := 20

# Rig the dice for debugging
@export var rigged_dice_value := -1

# Add any bonuses to the result
@export var static_bonus := 0
@export var add_three_point_bonus := false

var dice_roll_result := 0
var three_point_bonus := 0

func _init():
	super._init()
	action_type = StrategyCardActionNode.ActionType.ROLL_DICE

func process(blackboard: Blackboard):
	if rigged_dice_value != -1:
		dice_roll_result = rigged_dice_value
	else:
		dice_roll_result = randi_range(1, dice_type)
	if add_three_point_bonus:
		three_point_bonus = blackboard.off_player.ball_player_stats.three_point_bonus
	dice_roll_result += static_bonus + three_point_bonus
	var node_result = StrategyCardNode.NodeResult.new(StrategyCardNode.NodeResultType.SUCCESS, self)
	blackboard.node_results.append(node_result)
	return StrategyCardNode.NodeResultType.SUCCESS