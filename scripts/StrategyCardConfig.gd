class_name StrategyCardConfig
extends Resource

enum StrategyCardType {
  OFFENSE,
  DEFENSE
}

@export var strategy_type: StrategyCardType
@export var card_name: String
@export var card_description: String

@export_group("Condition Bonus 1")
@export var condition_1: Array[StrategyCardCondition]
@export var bonus_1: Array[StrategyCardBonus]

@export_group("Condition Bonus 2")
@export var condition_2: Array[StrategyCardCondition]
@export var bonus_2: Array[StrategyCardBonus]

@export_group("Condition Bonus 3")
@export var condition_3: Array[StrategyCardCondition]
@export var bonus_3: Array[StrategyCardBonus]

class ConditionBonusResult:
	var condition_results: Array[StrategyCardCondition.ConditionResult] = []
	var bonus_results: Array[StrategyCardBonus.BonusResult] = []
	func _init(_condition_results, _bonus_results):
		condition_results = _condition_results
		bonus_results = _bonus_results

func process(off_player: BallPlayerCard, def_player: BallPlayerCard):
	var condition_bonus_results = []
	if !condition_1.is_empty() and !bonus_1.is_empty():
		condition_bonus_results.append(process_condition_bonus(condition_1, bonus_1, off_player, def_player))
	if !condition_2.is_empty() and !bonus_2.is_empty():
		condition_bonus_results.append(process_condition_bonus(condition_2, bonus_2, off_player, def_player))
	if !condition_3.is_empty() and !bonus_3.is_empty():
		condition_bonus_results.append(process_condition_bonus(condition_3, bonus_3, off_player, def_player))
	return condition_bonus_results

func process_condition_bonus(conditions: Array[StrategyCardCondition], bonuses: Array[StrategyCardBonus], op: BallPlayerCard, dp: BallPlayerCard):
	var condition_results = []
	var bonus_results = []
	var should_apply_bonus_1 = true
	for c in conditions:
		var result = c.check_condition(op, dp)
		if result.result_type == StrategyCardCondition.ConditionResultType.FAILURE:
			should_apply_bonus_1 = false
		condition_results.append(result)
	if should_apply_bonus_1:
		for b in bonuses:
			bonus_results.append(b.apply_bonus(op, dp))
	return ConditionBonusResult.new(condition_results, bonus_results)