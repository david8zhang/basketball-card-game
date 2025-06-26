class_name BoxScoreBonus
extends StrategyCardBonusNode

enum StatType {
	POINTS,
	REBOUNDS,
	ASSISTS
}

@export var bonus_amt: int
@export var bonus_stat_type: StatType

func _init():
	super._init()
	bonus_type = StrategyCardBonusNode.BonusType.BOX_SCORE