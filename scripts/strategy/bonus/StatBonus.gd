class_name StatBonus
extends StrategyCardBonusNode

@export var off_bonus_amount := 0
@export var def_bonus_amount := 0

func _init():
  bonus_type = StrategyCardBonusNode.BonusType.STAT
