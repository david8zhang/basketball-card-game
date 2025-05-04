class_name MatchupContainer
extends Panel

@onready var hbox_container = $MarginContainer/VBoxContainer/HBoxContainer as HBoxContainer
@onready var roll_button = $MarginContainer/VBoxContainer/VBoxContainer/RollButton as Button
@onready var roll_value_label = $MarginContainer/VBoxContainer/VBoxContainer/RollValue as Label
@onready var close_button = $CloseButton as Button
@export var card_scene: PackedScene
@export var matchup_pts_assts_rebs_scene: PackedScene

var player_card: BallPlayerCard
var cpu_card: BallPlayerCard
var offense_side: Game.Side
var off_modifier_label: Label
var matchup_score: MatchupPtsAsstsRebs

signal calc_complete
signal matchup_complete(all_stats: Dictionary)

var calc_wflow_idx = 0
var calc_steps = []
var calc_delay_timer

func _ready():
	roll_button.pressed.connect(on_roll)
	close_button.pressed.connect(on_close_matchup_window)
	calc_complete.connect(process_calc_delay)

func set_player_card(card: BallPlayerCard):
	player_card = card_scene.instantiate() as BallPlayerCard
	player_card.ball_player_stats = card.ball_player_stats.duplicate()
	hbox_container.add_child(player_card)

func set_cpu_card(card: BallPlayerCard):
	cpu_card = card_scene.instantiate() as BallPlayerCard
	cpu_card.ball_player_stats = card.ball_player_stats.duplicate()
	hbox_container.add_child(cpu_card)

func set_offense_side(side: Game.Side):
	offense_side = side

func on_roll():
	roll_button.hide()
	calc_steps = [
		{
			"fname": "generate_roll_value",
			"on_comp_delay_s": 0.25
		},
		{
			"fname": "highlight_off_stat",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "highlight_def_stat",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "handle_off_modifier",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "reset_stat_highlight",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "push_roll_value_up",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "highlight_roll_table_row",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "tally_points",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "tally_assists",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "tally_rebounds",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "reset_roll_table_rows",
			"on_comp_delay_s": 0.1
		}
	]
	execute_calc_wflow()

func execute_calc_wflow():
	if calc_wflow_idx < calc_steps.size():
		var curr_step = calc_steps[calc_wflow_idx]
		var callable = Callable(self, curr_step["fname"])
		callable.call()

func process_calc_delay():
	var curr_step = calc_steps[calc_wflow_idx]
	if calc_delay_timer != null:
		calc_delay_timer.queue_free()
	calc_delay_timer = Timer.new()
	calc_delay_timer.autostart = true
	calc_delay_timer.wait_time = curr_step["on_comp_delay_s"]
	calc_delay_timer.one_shot = true
	var on_timeout = Callable(self, "go_to_next_calc")
	calc_delay_timer.timeout.connect(on_timeout)
	add_child(calc_delay_timer)

func go_to_next_calc():
	calc_wflow_idx += 1
	execute_calc_wflow()

func generate_roll_value():
	var random_number = randi_range(1, 20)
	roll_value_label.text = str(random_number)
	roll_value_label.show()
	calc_complete.emit()

func handle_off_modifier():
	var player_bp_stats = player_card.ball_player_stats
	var cpu_bp_stats = cpu_card.ball_player_stats
	var off_stat = player_bp_stats.offense if offense_side == Game.Side.PLAYER else cpu_bp_stats.offense
	var def_stat = cpu_bp_stats.defense if offense_side == Game.Side.PLAYER else player_bp_stats.defense
	var off_def_diff = off_stat - def_stat
	if off_def_diff != 0:
		off_modifier_label = Label.new()
		off_modifier_label.add_theme_font_size_override("font_size", 45)
		off_modifier_label.size.x = size.x
		off_modifier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		off_modifier_label.global_position = Vector2(0, roll_value_label.global_position.y + 100)
		off_modifier_label.text = "+" + str(off_def_diff) if off_def_diff > 0 else str(off_def_diff)
		add_child(off_modifier_label)

		# Combine modifier value with roll value
		var off_modifier_tween = create_tween()
		off_modifier_tween.tween_property(off_modifier_label, "global_position:y", roll_value_label.global_position.y + 10, 0.5).set_delay(1.0)
		var cb = Callable(self, "combine_off_modifier").bind(off_def_diff)
		off_modifier_tween.finished.connect(cb)
	else:
		calc_complete.emit()

func hide_off_modifier_label():
	off_modifier_label.hide()

func combine_off_modifier(off_def_diff: int):
	var new_roll_value = int(roll_value_label.text) + off_def_diff
	roll_value_label.text = str(new_roll_value)
	off_modifier_label.queue_free()
	calc_complete.emit()

func highlight_off_stat():
	var offense_bp_card = player_card if offense_side == Game.Side.PLAYER else cpu_card
	offense_bp_card.animation_player.animation_finished.connect(on_anim_finished)
	offense_bp_card.animation_player.play("highlight_offense_stat")

func highlight_def_stat():
	var defense_bp_card = cpu_card if offense_side == Game.Side.PLAYER else player_card
	defense_bp_card.animation_player.animation_finished.connect(on_anim_finished)
	defense_bp_card.animation_player.play("highlight_defense_stat")

func reset_stat_highlight():
	var defense_bp_card = cpu_card if offense_side == Game.Side.PLAYER else player_card
	var offense_bp_card = player_card if offense_side == Game.Side.PLAYER else cpu_card
	defense_bp_card.animation_player.animation_finished.disconnect(on_anim_finished) 	# prevent double firing of calc complete event
	offense_bp_card.animation_player.play_backwards("highlight_offense_stat")
	defense_bp_card.animation_player.play_backwards("highlight_defense_stat")

func on_anim_finished(anim_name: String):
	if anim_name == "highlight_offense_stat" or anim_name == "highlight_defense_stat":
		go_to_next_step_generic()

func get_table_row_for_roll_value():
	var roll_value = clamp(int(roll_value_label.text), 1, 30)
	var roll_table_row
	var offense_bp_card = player_card if offense_side == Game.Side.PLAYER else cpu_card
	for row in offense_bp_card.roll_table_rows:
		var roll_table_row_data = row["data"] as RollTableRow
		if roll_value >= roll_table_row_data.low and roll_value <= roll_table_row_data.high:
			roll_table_row = row
	assert(roll_table_row != null, "roll_table_row must not be null!")
	return roll_table_row

func highlight_roll_table_row():
	var roll_table_row = get_table_row_for_roll_value()
	var roll_range_label = roll_table_row["roll_range_label"] as TableValue
	var hl_row_range = create_tween()
	hl_row_range.tween_property(roll_range_label.label, "theme_override_font_sizes/font_size", 25, 0.5)
	hl_row_range.finished.connect(go_to_next_step_generic)

func dehighlight_roll_table_row():
	var roll_table_row = get_table_row_for_roll_value()
	var roll_range_label = roll_table_row["roll_range_label"] as TableValue
	var hl_row_range = create_tween()
	hl_row_range.tween_property(roll_range_label.label, "theme_override_font_sizes/font_size", 15, 0.5)
	hl_row_range.finished.connect(go_to_next_step_generic)

func push_roll_value_up():
	var tween = create_tween()
	var start_y = roll_value_label.global_position.y
	tween.tween_property(roll_value_label, "theme_override_font_sizes/font_size", 30, 0.5)

	var shrink_fn = func shrink_roll_value():
		var new_tween = create_tween()
		var end_y = roll_value_label.global_position.y - 100
		new_tween.tween_property(roll_value_label, "global_position:y", end_y, 0.5)
		new_tween.finished.connect(go_to_next_step_generic)

	tween.finished.connect(shrink_fn)
	matchup_score = matchup_pts_assts_rebs_scene.instantiate()
	add_child(matchup_score)
	matchup_score.global_position = Vector2(508, get_viewport_rect().size.y + 200)
	var tween_slide = create_tween()
	tween_slide.tween_property(matchup_score, "global_position:y", start_y, 1.0)

func go_to_next_step_generic():
	calc_complete.emit()
	
func tally_points():
	var roll_table_row = get_table_row_for_roll_value()
	var points_value = matchup_score.points_value	
	var points_scored = roll_table_row["points_label"] as TableValue
	var hl_points_scored = create_tween()
	hl_points_scored.tween_property(points_scored.label, "theme_override_font_sizes/font_size", 25, 0.5)

	var points_bonus_label = Label.new()
	add_child(points_bonus_label)
	points_bonus_label.text = "+" + ("0" if points_scored.label.text == "" else points_scored.label.text)
	points_bonus_label.global_position = Vector2(points_value.global_position.x, points_value.global_position.y + 75)
	points_bonus_label.add_theme_font_size_override("font_size", 50)
	points_bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var add_points_bonus_tween = create_tween()
	add_points_bonus_tween.tween_property(points_bonus_label, "global_position:y", points_value.global_position.y, 0.5).set_delay(0.5)

	var on_combine_finished = func on_combine_finished():
		var tween = create_tween()
		tween.tween_property(points_value, "theme_override_font_sizes/font_size", 50, 0.25)
		calc_complete.emit()

	var combine_fn = func combine_with_total_points():
		var tween = create_tween()
		points_bonus_label.queue_free()
		points_value.text = str(int(points_value.text) + int(points_scored.label.text))
		tween.tween_property(points_value, "theme_override_font_sizes/font_size", 60, 0.25)
		tween.finished.connect(on_combine_finished)
	
	add_points_bonus_tween.finished.connect(combine_fn)

func tally_assists():
	var roll_table_row = get_table_row_for_roll_value()
	var assists_value = matchup_score.assists_value
	var assists_made = roll_table_row["assists_label"] as TableValue
	var hl_assists_scored = create_tween()
	hl_assists_scored.tween_property(assists_made.label, "theme_override_font_sizes/font_size", 25, 0.5)

	var assists_bonus_label = Label.new()
	add_child(assists_bonus_label)
	assists_bonus_label.text = "+" + ("0" if assists_made.label.text == "" else assists_made.label.text)
	assists_bonus_label.global_position = Vector2(assists_value.global_position.x, assists_value.global_position.y + 75)
	assists_bonus_label.add_theme_font_size_override("font_size", 50)
	assists_bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var add_assists_bonus_tween = create_tween()
	add_assists_bonus_tween.tween_property(assists_bonus_label, "global_position:y", assists_value.global_position.y, 0.5).set_delay(0.5)

	var on_combine_finished = func on_combine_finished():
		var tween = create_tween()
		tween.tween_property(assists_value, "theme_override_font_sizes/font_size", 50, 0.25)
		calc_complete.emit()

	var combine_fn = func combine_with_total_points():
		var tween = create_tween()
		assists_bonus_label.queue_free()
		assists_value.text = str(int(assists_value.text) + int(assists_made.label.text))
		tween.tween_property(assists_value, "theme_override_font_sizes/font_size", 60, 0.25)
		tween.finished.connect(on_combine_finished)

	add_assists_bonus_tween.finished.connect(combine_fn)

func tally_rebounds():
	var roll_table_row = get_table_row_for_roll_value()
	var rebounds_value = matchup_score.rebounds_value
	var rebounds_grabbed = roll_table_row["rebounds_label"] as TableValue
	var hl_rebounds_grabbed = create_tween()
	hl_rebounds_grabbed.tween_property(rebounds_grabbed.label, "theme_override_font_sizes/font_size", 25, 0.5)

	var rebounds_bonus_label = Label.new()
	add_child(rebounds_bonus_label)
	rebounds_bonus_label.text = "+" + ("0" if rebounds_grabbed.label.text == "" else rebounds_grabbed.label.text)
	rebounds_bonus_label.global_position = Vector2(rebounds_value.global_position.x, rebounds_value.global_position.y + 75)
	rebounds_bonus_label.add_theme_font_size_override("font_size", 50)
	rebounds_bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var add_rebounds_bonus_tween = create_tween()
	add_rebounds_bonus_tween.tween_property(rebounds_bonus_label, "global_position:y", rebounds_value.global_position.y, 0.5).set_delay(0.5)

	var on_combine_finished = func on_combine_finished():
		var tween = create_tween()
		tween.tween_property(rebounds_value, "theme_override_font_sizes/font_size", 50, 0.25)
		calc_complete.emit()

	var combine_fn = func combine_with_total_points():
		var tween = create_tween()
		rebounds_bonus_label.queue_free()
		rebounds_value.text = str(int(rebounds_value.text) + int(rebounds_grabbed.label.text))
		tween.tween_property(rebounds_value, "theme_override_font_sizes/font_size", 60, 0.25)
		tween.finished.connect(on_combine_finished)
	add_rebounds_bonus_tween.finished.connect(combine_fn)	

func reset_roll_table_rows():
	var roll_table_row = get_table_row_for_roll_value()
	var roll_range_label = roll_table_row["roll_range_label"] as TableValue
	var rebounds_value_row = roll_table_row["rebounds_label"] as TableValue
	var assists_value_row = roll_table_row["assists_label"] as TableValue
	var points_value_row = roll_table_row["points_label"] as TableValue

	var tween = create_tween()
	tween.tween_property(roll_range_label.label, "theme_override_font_sizes/font_size", 15, 0.5)
	tween.parallel().tween_property(rebounds_value_row.label, "theme_override_font_sizes/font_size", 15, 0.5)
	tween.parallel().tween_property(assists_value_row.label, "theme_override_font_sizes/font_size", 15, 0.5)
	tween.parallel().tween_property(points_value_row.label, "theme_override_font_sizes/font_size", 15, 0.5)

	var on_continue_button = Button.new()
	on_continue_button.text = "Continue"
	add_child(on_continue_button)
	on_continue_button.add_theme_font_size_override("font_size", 20)
	on_continue_button.global_position.y = matchup_score.points_value.global_position.y + 90
	on_continue_button.global_position.x = matchup_score.assists_value.global_position.x
	on_continue_button.pressed.connect(on_matchup_completed)

func on_matchup_completed():
	var all_stats = matchup_score.get_all_stats()
	matchup_complete.emit(all_stats, offense_side)
	on_close_matchup_window()

func call_after_delay(delay_sec: float, func_name: String):
	var timer = Timer.new()
	timer.wait_time = delay_sec
	timer.autostart = true
	timer.one_shot = true
	var callable = Callable(self, "clear_delay_timer").bind(timer, func_name)
	timer.timeout.connect(callable)
	add_child(timer)

func clear_delay_timer(timer: Timer, func_name: String):
	var callable = Callable(self, func_name)
	callable.call()
	timer.queue_free()

func on_close_matchup_window():
	player_card.queue_free()
	cpu_card.queue_free()
	queue_free()

func hide_close_button():
	close_button.hide()