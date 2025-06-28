class_name BoxScoreBonus
extends StrategyCardBonusNode

enum StatType {
	POINTS,
	REBOUNDS,
	ASSISTS
}

enum TargetSide {
	OFFENSE,
	DEFENSE
}

@export var bonus_amt: int
@export var bonus_stat_type: StatType
@export var target_side: TargetSide

func _init():
	super._init()
	bonus_type = StrategyCardBonusNode.BonusType.BOX_SCORE