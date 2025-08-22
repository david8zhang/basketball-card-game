class_name DiceRollCondition
extends StrategyCardConditionNode

enum ComparatorType {
	LESS,
	EQUAL,
	GREATER
}

@export var dice_roll_thres := 0
@export var comparator_type := ComparatorType.GREATER
@export var check_initial_roll := false

var final_roll_result := 0
var dice_type := 0

func _init():
	super._init()
	condition_type = StrategyCardConditionNode.ConditionType.DICE_ROLL_CHECK

func check_condition(blackboard: Blackboard):  
	var roll_dice_action_result = get_roll_dice_action_result(blackboard) as RollDiceAction
	assert(roll_dice_action_result != null, "Roll dice action must exist!")
	final_roll_result = roll_dice_action_result.final_roll_result if !check_initial_roll else roll_dice_action_result.dice_roll_result
	dice_type = roll_dice_action_result.dice_type
	var result_type
	match (comparator_type):
		ComparatorType.LESS:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if \
			final_roll_result < dice_roll_thres else \
			StrategyCardNode.NodeResultType.FAILURE
		ComparatorType.EQUAL:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if \
			final_roll_result == dice_roll_thres else \
			StrategyCardNode.NodeResultType.FAILURE
		ComparatorType.GREATER:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if \
			final_roll_result > dice_roll_thres else \
			StrategyCardNode.NodeResultType.FAILURE
	return result_type

func get_roll_dice_action_result(blackboard: Blackboard):
	for result in blackboard.node_results:
		if result.node_ref.node_type == StrategyCardNode.NodeType.ACTION and result.node_ref.action_type == StrategyCardActionNode.ActionType.ROLL_DICE:
			return result.node_ref
		return null
