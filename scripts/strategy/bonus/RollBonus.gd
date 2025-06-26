class_name RollBonus
extends StrategyCardBonusNode

enum TargetType {
  OFF,
  DEF
}

@export var target_type: TargetType
@export var roll_bonus_amount := 0

func _init():
  bonus_type = StrategyCardBonusNode.BonusType.ROLL
