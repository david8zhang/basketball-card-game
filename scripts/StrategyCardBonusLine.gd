class_name StrategyCardBonusLine
extends HBoxContainer

@onready var attribute_label = $Attribute as Label
@onready var bonus_amount_label = $BonusAmount as Label

func setup(attr_name: String, bonus_amt: int):
	attribute_label.text = attr_name
	bonus_amount_label.text = "+" + str(bonus_amt)
