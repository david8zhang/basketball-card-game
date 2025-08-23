class_name TeamStatBonus
extends StrategyCardBonusNode

@export var off_bonus_amount := 0
@export var def_bonus_amount := 0

func _init():
	super._init()
	bonus_type = StrategyCardBonusNode.BonusType.TEAM_STAT_BONUS
