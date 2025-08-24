class_name GenericBonusAnimator
extends Control

@export var generic_bonus_label_scene: PackedScene

enum BonusAnimDirection {
	BOTTOM_LEFT,
	BOTTOM_RIGHT
}

signal on_anim_complete

func _ready():
  animate_generic_bonus(5, BonusAnimDirection.BOTTOM_RIGHT, "prefix ", " suffix")

func animate_generic_bonus(bonus_amt: int, direction: BonusAnimDirection, bonus_prefix: String = "", bonus_suffix: String = ""):
  var label = generic_bonus_label_scene.instantiate()
  label.text = bonus_prefix + str(bonus_amt) + bonus_suffix
  add_child(label)

  var zoom_tween = create_tween()
  zoom_tween.set_trans(Tween.TRANS_SINE)
  zoom_tween.set_ease(Tween.EASE_IN_OUT)
  zoom_tween.tween_property(label, "theme_override_font_sizes/font_size", 35, 0.25)

  var screen_size = get_viewport_rect().size
  var bottom_right = Vector2(screen_size.x + 50, screen_size.y + 50)
  var bottom_left = Vector2(0, screen_size.y + 50)

  var on_pan_complete = func _on_pan_complete():
    label.queue_free()
    on_anim_complete.emit()

  var pan_to_corner = func _pan_to_corner():
    var tween = create_tween()
    var final_pos = bottom_right if direction == BonusAnimDirection.BOTTOM_RIGHT else bottom_left
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(label, "global_position", final_pos, 1.0)
    tween.finished.connect(on_pan_complete)

  var zoom_complete = func _zoom_complete():
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_IN_OUT)		
    tween.tween_property(label, "theme_override_font_sizes/font_size", 20, 0.25).set_delay(0.25)
    tween.finished.connect(pan_to_corner)

  zoom_tween.finished.connect(zoom_complete)
