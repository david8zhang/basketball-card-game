class_name StrategyCardBonus
extends Resource

enum StrategyCardBonusType {
  STAT,
  ROLL,
  SCORE
}

@export var bonus_type: StrategyCardBonusType

class BonusResult:
  var bonus_type: StrategyCardBonusType
  func _init(_bonus_type):
    bonus_type = _bonus_type


func apply_bonus(_off_player: BallPlayerCard, _def_player: BallPlayerCard):
  pass