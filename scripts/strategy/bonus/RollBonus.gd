class_name RollBonus
extends StrategyCardBonusNode

enum RollBonusType {
	STATIC_BONUS,
	OFF_DIFF,
	DEF_DIFF,
	THREE_PT_BONUS
}

@export var roll_bonus_amount := 0
@export var roll_bonus_type: RollBonusType

func _init():
	super._init()
	bonus_type = StrategyCardBonusNode.BonusType.ROLL

func process(blackboard: Blackboard):
	var off_player_stats = blackboard.off_player.ball_player_stats
	var def_player_stats = blackboard.def_player.ball_player_stats
	var strategy_type = blackboard.card_config.strategy_type
	if roll_bonus_type == RollBonusType.STATIC_BONUS:
		return super.process(blackboard)
	elif roll_bonus_type == RollBonusType.OFF_DIFF:
		var off_stat = off_player_stats.offense if strategy_type == StrategyCardConfig.StrategyCardType.OFFENSE else def_player_stats.offense
		var def_stat = def_player_stats.defense if strategy_type == StrategyCardConfig.StrategyCardType.OFFENSE else off_player_stats.defense
		var off_diff = off_stat - def_stat
		if off_diff > 0:
			roll_bonus_amount = off_diff
		var result_type = StrategyCardNode.NodeResultType.SUCCESS if off_diff > 0 else StrategyCardNode.NodeResultType.FAILURE
		add_result_to_bb(result_type, blackboard)
		return result_type
	elif roll_bonus_type == RollBonusType.DEF_DIFF:
		var def_stat = off_player_stats.defense if strategy_type == StrategyCardConfig.StrategyCardType.OFFENSE else def_player_stats.defense
		var off_stat = def_player_stats.offense if strategy_type == StrategyCardConfig.StrategyCardType.OFFENSE else off_player_stats.offense
		var def_diff = def_stat - off_stat
		if def_diff > 0:
			roll_bonus_amount = def_diff
		var result_type = StrategyCardNode.NodeResultType.SUCCESS if def_diff > 0 else StrategyCardNode.NodeResultType.FAILURE
		add_result_to_bb(result_type, blackboard)
		return result_type
	elif roll_bonus_type == RollBonusType.THREE_PT_BONUS:
		var three_pt_bonus = off_player_stats.three_point_bonus if strategy_type == StrategyCardConfig.StrategyCardType.OFFENSE else def_player_stats.three_point_bonus
		if three_pt_bonus > 0:
			roll_bonus_amount = three_pt_bonus
		var result_type = StrategyCardNode.NodeResultType.SUCCESS if three_pt_bonus > 0 else StrategyCardNode.NodeResultType.FAILURE
		add_result_to_bb(result_type, blackboard)
		return result_type
