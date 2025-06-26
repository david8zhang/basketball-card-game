class_name FreeThrowBonus
extends StrategyCardBonusNode

enum FreeThrowPlayerSide {
	OFF,
	DEF
}

@export var free_throw_player_side: FreeThrowPlayerSide

func _init():
	super._init()
	bonus_type = StrategyCardBonusNode.BonusType.FREE_THROWS