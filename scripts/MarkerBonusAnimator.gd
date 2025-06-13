class_name MarkerBonusAnimator
extends Control

signal on_complete

func update_marker_value(marker: Marker, new_value: int, marker_type: Marker.MarkerType):
	marker.update_marker_with_type(new_value, marker_type)
	var reset_tween = create_tween()
	reset_tween.tween_property(marker.label, "theme_override_font_sizes/font_size", 18, 0.5).set_delay(1)
	var callable = Callable(self, "on_stat_update_complete")
	reset_tween.finished.connect(callable)

func on_stat_update_complete():
	on_complete.emit()

func apply_bonus_to_player(off_bp_card: BallPlayerCard, def_bp_card: BallPlayerCard, marker_bonus: MarkerBonus):
	match (marker_bonus.marker_type):
		MarkerBonus.MarkerType.HOT_ON_OFF:
			animate_marker(off_bp_card.marker, marker_bonus.num_markers, Marker.MarkerType.HOT)
		MarkerBonus.MarkerType.COLD_ON_OFF:
			animate_marker(off_bp_card.marker, marker_bonus.num_markers, Marker.MarkerType.COLD)
		MarkerBonus.MarkerType.HOT_ON_DEF:
			animate_marker(def_bp_card.marker, marker_bonus.num_markers, Marker.MarkerType.HOT)
		MarkerBonus.MarkerType.COLD_ON_DEF:
			animate_marker(def_bp_card.marker, marker_bonus.num_markers, Marker.MarkerType.COLD)

# Called when the node enters the scene tree for the first time.
func animate_marker(marker: Marker, new_value: int, marker_type: Marker.MarkerType):
	marker.show()
	var tween = create_tween()
	tween.tween_property(marker.label, "theme_override_font_sizes/font_size", 25, 0.5)
	var callable = Callable(self, "update_marker_value").bind(marker, new_value, marker_type)
	tween.finished.connect(callable)
