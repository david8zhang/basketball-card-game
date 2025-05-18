class_name StrategyCardConditionBonus
extends Resource

# If all conditions pass, apply all bonuses
@export var conditions: Array[StrategyCardCondition] = []
@export var bonuses: Array[StrategyCardBonus] = []

class ConditionBonusResult:
	var condition_results: Array[StrategyCardCondition.ConditionResult] = []
	var bonus_results: Array[StrategyCardBonus.BonusResult] = []

	func _init(_condition_results, _bonus_results):
		condition_results = _condition_results
		bonus_results = _bonus_results


# Returns a list of condition results, which is a dictionary containing roll results, shot checks, etc.
func process(off_player: BallPlayerCard, def_player: BallPlayerCard):
	var condition_results = []
	var bonus_results = []
	var should_apply_bonus := true
	for c in conditions:
		var result = c.check_condition(off_player, def_player) as StrategyCardCondition.ConditionResult
		if result.result_type == StrategyCardCondition.ConditionResultType.FAILURE:
			should_apply_bonus = false
		condition_results.append(result)
	if should_apply_bonus:
		for b in bonuses:
			bonus_results.append(b.apply_bonus(off_player, def_player))