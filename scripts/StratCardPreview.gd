class_name StratCardPreview
extends Node

@onready var control = $Control
@onready var game = get_node("/root/Main") as Game
@export var strategy_card_scene: PackedScene

func show_strategy_card(sc: StrategyCard, callable: Callable):
	control.show()
	var strategy_card = strategy_card_scene.instantiate() as StrategyCard
	strategy_card.strategy_card_config = sc.strategy_card_config
	control.add_child(strategy_card)
	var prev_y = strategy_card.global_position.y
	var prev_x = strategy_card.global_position.x
	strategy_card.global_position = Vector2(sc.global_position.x, sc.global_position.y)

	var on_slide_in_complete = func slide_in_complete():
		var fade_tween = create_tween()
		fade_tween.tween_property(strategy_card, "modulate:a", 0, 0.5).set_delay(1.5)
		fade_tween.finished.connect(callable)

	var slide_in = create_tween()
	slide_in.set_trans(Tween.TRANS_SINE)
	slide_in.set_ease(Tween.EASE_IN_OUT)
	slide_in.tween_property(strategy_card, "global_position", Vector2(prev_x, prev_y), 1.0)
	slide_in.finished.connect(on_slide_in_complete)

func hide_strategy_card():
	control.hide()