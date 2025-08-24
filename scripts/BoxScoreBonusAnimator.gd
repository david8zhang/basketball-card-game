class_name BoxScoreBonusAnimator
extends Control

@export var box_score_bonus_label_scene: PackedScene
@export var test_box_score_bonus: BoxScoreBonus

signal on_box_score_bonus_complete

func _ready():
  animate_box_score_bonus(test_box_score_bonus, true)

func animate_box_score_bonus(box_score_bonus: BoxScoreBonus, is_cpu: bool):
  var label = box_score_bonus_label_scene.instantiate()
  var stat_name = ""
  match box_score_bonus.bonus_stat_type:
    BoxScoreBonus.StatType.POINTS:
      stat_name = "point"
    BoxScoreBonus.StatType.ASSISTS:
      stat_name = "assist"
    BoxScoreBonus.StatType.REBOUNDS:
      stat_name = "rebound"
  stat_name = stat_name + "s" if abs(box_score_bonus.bonus_amt) > 0 else stat_name
  label.text = ("+" if box_score_bonus.bonus_amt > 0 else "") + str(box_score_bonus.bonus_amt) + " " + stat_name
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
    on_box_score_bonus_complete.emit()

  var pan_to_corner = func _pan_to_corner():
    var tween = create_tween()
    var final_pos = bottom_right if is_cpu else bottom_left
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
