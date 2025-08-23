class_name ThreePointBonusCondition
extends StrategyCardConditionNode

enum PlayerToCheck {
	OFFENSE_PLAYER,
	DEFENSE_PLAYER
}

@export var player_to_check: PlayerToCheck = PlayerToCheck.OFFENSE_PLAYER
@export var has_bonus: bool = true  # true = check if player HAS bonus, false = check if player has NO bonus

func _init():
	super._init()
	condition_type = StrategyCardConditionNode.ConditionType.THREE_POINT_BONUS_CHECK

func check_condition(blackboard: Blackboard) -> StrategyCardNode.NodeResultType:
	var player = get_player_to_check(blackboard)
	var player_has_bonus = player.ball_player_stats.three_point_bonus > 0
	
	# If has_bonus is true, return SUCCESS when player has bonus
	# If has_bonus is false, return SUCCESS when player has no bonus
	if has_bonus == player_has_bonus:
		return StrategyCardNode.NodeResultType.SUCCESS
	else:
		return StrategyCardNode.NodeResultType.FAILURE

func get_player_to_check(blackboard: Blackboard) -> BallPlayerCard:
	match player_to_check:
		PlayerToCheck.OFFENSE_PLAYER:
			return blackboard.off_player
		PlayerToCheck.DEFENSE_PLAYER:
			return blackboard.def_player
		_:
			return blackboard.off_player  # Default fallback
