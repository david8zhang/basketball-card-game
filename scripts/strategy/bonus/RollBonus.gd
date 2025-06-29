class_name RollBonus
extends StrategyCardBonusNode

@export var roll_bonus_amount := 0

func _init():
  super._init()
  bonus_type = StrategyCardBonusNode.BonusType.ROLL
