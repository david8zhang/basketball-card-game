class_name StatCompCondition
extends StrategyCardConditionNode

enum StatToComp {
	OFFENSE,
	DEFENSE
}

enum StatCompType {
	GREATER,
	LESS,
	EQUAL
}

@export var stat_to_comp: StatToComp
@export var comp_type: StatCompType

func _init():
	condition_type = StrategyCardConditionNode.ConditionType.STAT_COMP

func check_condition(blackboard: Blackboard):
	var off_player = blackboard.off_player as BallPlayerCard
	var def_player = blackboard.def_player as BallPlayerCard
	var off_bp_stats = off_player.ball_player_stats
	var def_bp_stats = def_player.ball_player_stats
	var off_player_stat = off_bp_stats.offense if stat_to_comp == StatToComp.OFFENSE else off_bp_stats.defense
	var def_player_stat = def_bp_stats.offense if stat_to_comp == StatToComp.OFFENSE else def_bp_stats.defense
	var result_type := StrategyCardNode.NodeResultType.SUCCESS
	match comp_type:
		StatCompType.GREATER:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if off_player_stat > def_player_stat else StrategyCardNode.NodeResultType.FAILURE
		StatCompType.LESS:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if off_player_stat < def_player_stat else StrategyCardNode.NodeResultType.FAILURE
		StatCompType.EQUAL:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if off_player_stat == def_player_stat else StrategyCardNode.NodeResultType.FAILURE
	return result_type
