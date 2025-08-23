class_name StatBonusAnimator
extends Control

enum BonusType {
	ADD,
	SUBTRACT
}

signal on_complete

func update_stat_value(label: Label, new_value: int, bonus_type: BonusType):
	label.text = str(new_value)
	var font_color_override = Color(0, 1, 0) if bonus_type == BonusType.ADD else Color(1, 0, 0)
	label.add_theme_color_override("font_color", font_color_override)
	var reset_tween = create_tween()
	reset_tween.tween_property(label, "theme_override_font_sizes/font_size", 50, 0.25).set_delay(1.0)
	var callable = Callable(self, "on_stat_update_complete")
	reset_tween.finished.connect(callable)

func on_stat_update_complete():
	on_complete.emit()

func apply_bonus_to_player(off_amt: int, def_amt: int, player: BallPlayerCard):
	if off_amt > 0:
		animate_bonus(player.offense_value, off_amt, BonusType.ADD)
	if def_amt > 0:
		animate_bonus(player.defense_value, def_amt, BonusType.ADD)

func animate_bonus(label: Label, bonus_amt: int, bonus_type: BonusType):
	var tween = create_tween()
	tween.tween_property(label, "theme_override_font_sizes/font_size", 70, 0.25)
	var new_value = int(label.text) + bonus_amt
	var callable = Callable(self, "update_stat_value").bind(label, new_value, bonus_type)
	tween.finished.connect(callable)