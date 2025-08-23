class_name StatCheckCondition
extends StrategyCardConditionNode

enum StatType {
	OFFENSE,
	DEFENSE
}

enum ComparatorType {
	LESS,
	EQUAL,
	GREATER,
	LESS_EQUAL,
	GREATER_EQUAL
}

enum PlayerToCheck {
	OFFENSE_PLAYER,
	DEFENSE_PLAYER
}

@export var stat_to_check: StatType
@export var comparator_type: ComparatorType
@export var threshold: int = 0
@export var player_to_check: PlayerToCheck = PlayerToCheck.OFFENSE_PLAYER

func _init():
	super._init()
	condition_type = StrategyCardConditionNode.ConditionType.STAT_CHECK

func check_condition(blackboard: Blackboard) -> StrategyCardNode.NodeResultType:
	var player = get_player_to_check(blackboard)
	var player_stat = get_player_stat(player)
	var result_type: StrategyCardNode.NodeResultType
	
	match comparator_type:
		ComparatorType.LESS:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if \
			player_stat < threshold else \
			StrategyCardNode.NodeResultType.FAILURE
		ComparatorType.EQUAL:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if \
			player_stat == threshold else \
			StrategyCardNode.NodeResultType.FAILURE
		ComparatorType.GREATER:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if \
			player_stat > threshold else \
			StrategyCardNode.NodeResultType.FAILURE
		ComparatorType.LESS_EQUAL:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if \
			player_stat <= threshold else \
			StrategyCardNode.NodeResultType.FAILURE
		ComparatorType.GREATER_EQUAL:
			result_type = StrategyCardNode.NodeResultType.SUCCESS if \
			player_stat >= threshold else \
			StrategyCardNode.NodeResultType.FAILURE
	
	return result_type

func get_player_to_check(blackboard: Blackboard) -> BallPlayerCard:
	match player_to_check:
		PlayerToCheck.OFFENSE_PLAYER:
			return blackboard.off_player
		PlayerToCheck.DEFENSE_PLAYER:
			return blackboard.def_player
		_:
			return blackboard.off_player  # Default fallback

func get_player_stat(player: BallPlayerCard) -> int:
	match stat_to_check:
		StatType.OFFENSE:
			return int(player.offense_value.text)
		StatType.DEFENSE:
			return int(player.defense_value.text)
		_:
			return 0
