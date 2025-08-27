class_name PointDiffCondition
extends StrategyCardConditionNode

enum CompType {
	GREATER,
	LESS,
	EQUAL,
	GREATER_EQUAL,
	LESS_EQUAL
}

@export var point_diff_threshold := 0
@export var comp_type: CompType

func check_condition(blackboard: Blackboard):
	var offense_side = blackboard.game_state["offense_side"]
	var offense_score = blackboard.game_state["player_score"] if offense_side == Game.Side.PLAYER else blackboard.game_state["cpu_score"]
	var defense_score = blackboard.game_state["cpu_score"] if offense_side == Game.Side.PLAYER else blackboard.game_state["player_score"]
	var point_diff = offense_score - defense_score
	return StrategyCardNode.NodeResultType.SUCCESS if check_point_diff_requirement(point_diff) else StrategyCardNode.NodeResultType.FAILURE

func check_point_diff_requirement(point_diff: int):
	match comp_type:
		CompType.GREATER:
			return point_diff > point_diff_threshold
		CompType.LESS:
			return point_diff < point_diff_threshold
		CompType.EQUAL:
			return point_diff == point_diff_threshold
		CompType.GREATER_EQUAL:
			return point_diff >= point_diff_threshold
		CompType.LESS_EQUAL:
			return point_diff <= point_diff_threshold