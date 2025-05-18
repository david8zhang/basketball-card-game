class_name RollBonus
extends StrategyCardBonus

@export var roll_bonus_amount := 0

class RollBonusResult extends StrategyCardBonus.BonusResult:
  var roll_bonus_amount := 0
  func _init(_roll_bonus_amount):
    super._init(StrategyCardBonusType.ROLL)
    roll_bonus_amount = _roll_bonus_amount
    
func apply_bonus(_off_player: BallPlayerCard, _def_player: BallPlayerCard):
  return RollBonusResult.new(roll_bonus_amount)