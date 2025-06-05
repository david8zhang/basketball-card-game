class_name StatBonusAnimator
extends Control

func update_stat_value(label: Label, new_value: int):
	label.text = str(new_value)
	var reset_tween = create_tween()
	reset_tween.tween_property(label, "theme_override_font_sizes/font_size", 50, 0.5).set_delay(1.0)

func apply_bonus_to_player(off_amt: int, def_amt: int, player: BallPlayerCard):
	print("off amt: " + str(off_amt))
	print("def amt: " + str(def_amt))
	if off_amt > 0:
		animate_bonus(player.offense_value, off_amt)
	if def_amt > 0:
		animate_bonus(player.defense_value, def_amt)

func animate_bonus(label: Label, bonus_amt: int):
	var tween = create_tween()
	tween.tween_property(label, "theme_override_font_sizes/font_size", 65, 0.5)
	var new_value = int(label.text) + bonus_amt
	var callable = Callable(self, "update_stat_value").bind(label, new_value)
	tween.finished.connect(callable)