class_name TeamStatBonus
extends StrategyCardBonusNode

enum StatType {
	OFFENSE,
	DEFENSE,
	SHOT_CHECK,
	THREE_PT_BONUS
}

enum SideToReceive {
	OFFENSE,
	DEFENSE
}

@export var bonus_amt: int = 0
@export var stat_type: StatType
@export var side_to_receive: SideToReceive

func _init():
	super._init()
	bonus_type = StrategyCardBonusNode.BonusType.TEAM_STAT
