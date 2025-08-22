class_name StrategyCardBonusLine
extends HBoxContainer

@onready var attribute_label = $Attribute as Label
@onready var bonus_amount_label = $BonusAmount as Label

func setup(attr_name: String, bonus_amt: int, prefix: String = ""):
  attribute_label.text = attr_name
  var operator = prefix + " " + "+" if bonus_amt > 0 else "-"
  bonus_amount_label.text = operator + str(abs(bonus_amt))