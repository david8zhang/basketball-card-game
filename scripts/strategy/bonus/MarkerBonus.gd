class_name MarkerBonus
extends StrategyCardBonusNode

enum MarkerType {
  HOT_ON_OFF,
  COLD_ON_OFF,
  HOT_ON_DEF,
  COLD_ON_DEF
}

func _init():
  super._init()
  bonus_type = StrategyCardBonusNode.BonusType.MARKER

@export var marker_type: MarkerType
@export var num_markers := 0