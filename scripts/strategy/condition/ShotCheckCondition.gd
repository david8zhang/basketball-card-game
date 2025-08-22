class_name ShotCheckCondition
extends StrategyCardConditionNode

enum ShotCheckSide {
	OFFENSE,
	DEFENESE
}

@export var side_to_check: ShotCheckSide

func _init() -> void:
	super._init()
	condition_type = StrategyCardConditionNode.ConditionType.SHOT_CHECK

func check_condition(blackboard: Blackboard):
	var player_to_check = blackboard.off_player if side_to_check == ShotCheckSide.OFFENSE else blackboard.def_player
	var bp_stats = player_to_check.ball_player_stats
	var roll_dice_action_result = get_roll_dice_action_result(blackboard) as RollDiceAction
	assert(roll_dice_action_result != null, "Roll dice action must exist!")
	var final_roll_result = roll_dice_action_result.final_roll_result
	print(str(bp_stats.shot_check) + ", " + str(final_roll_result))
	return StrategyCardNode.NodeResultType.SUCCESS if final_roll_result > bp_stats.shot_check else StrategyCardNode.NodeResultType.FAILURE

func get_roll_dice_action_result(blackboard: Blackboard):
	var latest_dice_roll_result
	for result in blackboard.node_results:
		if result.node_ref.node_type == StrategyCardNode.NodeType.ACTION and result.node_ref.action_type == StrategyCardActionNode.ActionType.ROLL_DICE:
			latest_dice_roll_result = result.node_ref
	return latest_dice_roll_result
