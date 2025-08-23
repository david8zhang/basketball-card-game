class_name MarkerCheckCondition
extends StrategyCardConditionNode

enum MarkerType {
	ANY,      # Check for any marker (hot or cold)
	HOT,      # Check specifically for hot markers
	COLD,     # Check specifically for cold markers
	HOT_OR_COLD  # Check for either hot or cold (but not none)
}

enum PlayerToCheck {
	OFFENSE_PLAYER,
	DEFENSE_PLAYER
}

@export var marker_type: MarkerType = MarkerType.ANY
@export var player_to_check: PlayerToCheck = PlayerToCheck.OFFENSE_PLAYER
@export var min_marker_count: int = 1  # Minimum number of markers required

func _init():
	super._init()
	condition_type = StrategyCardConditionNode.ConditionType.MARKER_CHECK

func check_condition(blackboard: Blackboard) -> StrategyCardNode.NodeResultType:
	var player = get_player_to_check(blackboard)
	var marker = player.marker
	
	# Check if the player has the required markers
	var has_required_markers = check_marker_requirements(marker)
	
	return StrategyCardNode.NodeResultType.SUCCESS if has_required_markers else StrategyCardNode.NodeResultType.FAILURE

func get_player_to_check(blackboard: Blackboard) -> BallPlayerCard:
	match player_to_check:
		PlayerToCheck.OFFENSE_PLAYER:
			return blackboard.off_player
		PlayerToCheck.DEFENSE_PLAYER:
			return blackboard.def_player
		_:
			return blackboard.off_player  # Default fallback

func check_marker_requirements(marker: Marker) -> bool:
	# First check if we have enough markers
	if marker.curr_marker_count < min_marker_count:
		return false
	
	# Then check the marker type requirements
	match marker_type:
		MarkerType.ANY:
			# Any marker type is fine as long as count >= min_marker_count
			return true
		MarkerType.HOT:
			# Must have hot markers
			return marker.curr_marker_type == Marker.MarkerType.HOT
		MarkerType.COLD:
			# Must have cold markers
			return marker.curr_marker_type == Marker.MarkerType.COLD
		MarkerType.HOT_OR_COLD:
			# Must have either hot or cold (but not none)
			return marker.curr_marker_type != Marker.MarkerType.NONE
		_:
			return false
