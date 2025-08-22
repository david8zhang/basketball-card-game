class_name MatchupContainer
extends Panel

@onready var game = get_node("/root/Main") as Game
@onready var strategy_card_preview = $StratCardPreview
@onready var hbox_container = $MarginContainer/VBoxContainer/HBoxContainer as HBoxContainer
@onready var roll_button = $MarginContainer/VBoxContainer/VBoxContainer/RollButton as Button
@onready var roll_value_label = $MarginContainer/VBoxContainer/VBoxContainer/RollValue as Label
@onready var close_button = $CloseButton as Button
@onready var use_assists_checkbox = $MarginContainer/VBoxContainer/VBoxContainer/UseAssistsCheckbox as CheckBox
@onready var use_strategy_card_button = $MarginContainer/VBoxContainer/VBoxContainer/StratButton as Button
@onready var strat_roll_bonus_label = $MarginContainer/VBoxContainer/VBoxContainer/StratRollBonus as Label

# For animating bonuses from strategy cards
@onready var stat_bonus_animator: StatBonusAnimator = $StatBonusAnimator
@onready var marker_bonus_animator: MarkerBonusAnimator = $MarkerBonusAnimator
@onready var box_score_bonus_animator: BoxScoreBonusAnimator = $BoxScoreBonusAnimator

@export var card_scene: PackedScene
@export var matchup_pts_assts_rebs_scene: PackedScene
@export var strategy_card_selector_scene: PackedScene

var player_card: BallPlayerCard
var cpu_card: BallPlayerCard
var offense_side: Game.Side

# Labels for bonuses
var off_modifier_label: Label
var assists_modifier_label: Label
var hot_cold_modifier_label: Label
var strat_roll_bonus_modifier_label: Label

# Stats
var matchup_score: MatchupPtsAsstsRebs
var curr_assists := 0

# Strategy cards
var strategy_card_selector: StrategyCardSelector
var strategy_roll_bonuses := 0
var strategy_point_bonuses := 0
var strategy_rebound_bonuses := 0
var strategy_assist_bonuses := 0
var did_use_strategy_card := false
var is_cpu_using_strategy_card := false
var did_opp_use_def_strategy_card := false

signal calc_complete
signal matchup_complete(all_stats: Dictionary, side: Game.Side, assists_used: int)

var calc_wflow_idx = 0
var calc_steps = []
var calc_delay_timer

func _ready():
	roll_button.pressed.connect(on_start_turn)
	close_button.pressed.connect(on_close_matchup_window)
	calc_complete.connect(process_calc_delay)
	use_strategy_card_button.pressed.connect(show_strategy_card_selector)
	strat_roll_bonus_label.hide()
	box_score_bonus_animator.hide()
	# Hide use strategy card button if player has no strategy cards available
	if offense_side == Game.Side.PLAYER:
		var player_team = game.player_team
		var strat_deck = player_team.strategy_card_deck as StrategyCardDeck
		if strat_deck.get_offense_strategy_cards().size() == 0:
			use_strategy_card_button.hide()
		else:
			use_strategy_card_button.show()

func set_player_card(card: BallPlayerCard):
	player_card = card_scene.instantiate() as BallPlayerCard
	player_card.ball_player_stats = card.ball_player_stats.duplicate()
	hbox_container.add_child(player_card)
	player_card.marker.copy_from_marker(card.marker)

func set_cpu_card(card: BallPlayerCard):
	cpu_card = card_scene.instantiate() as BallPlayerCard
	cpu_card.ball_player_stats = card.ball_player_stats.duplicate()
	hbox_container.add_child(cpu_card)
	cpu_card.marker.copy_from_marker(card.marker)

func set_curr_assists(assists: int):
	curr_assists = assists
	if curr_assists == 0:
		use_assists_checkbox.hide()
	else:
		use_assists_checkbox.text = "Use " + str(curr_assists) + " assists"

func set_offense_side(side: Game.Side):
	offense_side = side

func cpu_use_off_strategy_card():
	var cpu_team = game.cpu_team
	var cpu_strat_deck = cpu_team.strategy_card_deck as StrategyCardDeck
	var cards_to_pick_from = cpu_strat_deck.get_offense_strategy_cards()
	if cards_to_pick_from.size() > 0:
		is_cpu_using_strategy_card = true
		var rand_index = randi_range(0, cards_to_pick_from.size() - 1)
		cpu_team.use_strategy_card(self, rand_index, cards_to_pick_from)
	else:
		var player_team = game.player_team
		var player_strat_deck = player_team.strategy_card_deck as StrategyCardDeck
		var player_def_cards = player_strat_deck.get_defense_strategy_cards()
		if player_def_cards.size() > 0:
			use_strategy_card_button.show()
			roll_button.show() # provide option to NOT use strategy card also
			roll_button.text = "CPU Roll"
		else:
			process_scoring_roll()

func cpu_use_def_strategy_card():
	var cpu_team = game.cpu_team
	var cpu_strat_deck = cpu_team.strategy_card_deck as StrategyCardDeck
	var cards_to_pick_from = cpu_strat_deck.get_defense_strategy_cards()
	var rand_index = randi_range(0, cards_to_pick_from.size() - 1)
	if cards_to_pick_from.size() > 0:
		is_cpu_using_strategy_card = true
		cpu_team.use_strategy_card(self, rand_index, cards_to_pick_from)
	else:
		# If no CPU defensive strategy cards, just move on to process player roll
		process_scoring_roll()

func on_process_player_def_strategy_complete():
	roll_button.text = "CPU Roll"
	roll_button.show()

func on_process_player_off_strategy_complete():
	roll_button.text = "Roll"
	if curr_assists > 0:
		use_assists_checkbox.show()
	roll_button.show()

func on_process_cpu_def_strategy_complete():
	roll_button.text = "Roll"
	roll_button.show()

func on_process_cpu_off_strategy_complete():
	var player_team = game.player_team
	var player_strat_deck = player_team.strategy_card_deck as StrategyCardDeck
	var player_def_cards = player_strat_deck.get_defense_strategy_cards()
	if player_def_cards.size() > 0 and !did_opp_use_def_strategy_card:
		use_strategy_card_button.show()
	roll_button.text = "CPU Roll"
	roll_button.show()

func process_scoring_roll():
	roll_button.hide()
	calc_steps = [
		{
			"fname": "generate_roll_value",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "add_strat_bonus_to_roll",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "add_assists_to_roll",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "add_hot_or_cold_modifiers",
			"on_comp_delay_s": 0.1
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
			"fname": "tally_strat_bonus_points",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "tally_assists",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "tally_strat_bonus_assists",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "tally_rebounds",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "tally_strat_bonus_rebounds",
			"on_comp_delay_s": 0.1
		},
		{
			"fname": "reset_roll_table_rows",
			"on_comp_delay_s": 0.1
		}
	]
	execute_calc_wflow()

func on_start_turn():
	roll_button.hide()
	if offense_side == Game.Side.PLAYER and !did_opp_use_def_strategy_card:
		cpu_use_def_strategy_card()
	else:
		process_scoring_roll()

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
	use_assists_checkbox.hide()
	use_strategy_card_button.hide()
	strat_roll_bonus_label.hide()
	var random_number = randi_range(1, 20)
	var off_bp_card = get_off_player_card()
	if random_number == 1:
		off_bp_card.add_cold_marker()
	elif random_number == 20:
		off_bp_card.add_hot_marker()
	roll_value_label.text = str(random_number)
	roll_value_label.show()
	calc_complete.emit()

func combine_strat_bonus_modifier():
	var new_roll_value = int(roll_value_label.text) + strategy_roll_bonuses
	roll_value_label.text = str(new_roll_value)
	strat_roll_bonus_modifier_label.queue_free()
	calc_complete.emit()

func add_strat_bonus_to_roll():
	if strategy_roll_bonuses != 0:
		strat_roll_bonus_modifier_label = Label.new()
		strat_roll_bonus_modifier_label.add_theme_font_size_override("font_size", 35)
		strat_roll_bonus_modifier_label.size.x = size.x
		strat_roll_bonus_modifier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		strat_roll_bonus_modifier_label.global_position = Vector2(0, roll_value_label.global_position.y + 100)
		var operator = "+" if strategy_roll_bonuses > 0 else "-"
		strat_roll_bonus_modifier_label.text = operator + str(abs(strategy_roll_bonuses))
		add_child(strat_roll_bonus_modifier_label)
		# Combine assists with roll value
		var strat_roll_modifier_tween = create_tween()
		strat_roll_modifier_tween.tween_property(strat_roll_bonus_modifier_label, "global_position:y", roll_value_label.global_position.y + 10, 0.25).set_delay(0.5)
		var cb = Callable(self, "combine_strat_bonus_modifier")
		strat_roll_modifier_tween.finished.connect(cb)
	else:
		calc_complete.emit()

func combine_assists_modifier(assists_modifier: int):
	var new_roll_value = int(roll_value_label.text) + assists_modifier
	roll_value_label.text = str(new_roll_value)
	assists_modifier_label.queue_free()
	calc_complete.emit()

func add_assists_to_roll():
	if use_assists_checkbox.button_pressed and curr_assists > 0:
		assists_modifier_label = Label.new()
		assists_modifier_label.add_theme_font_size_override("font_size", 35)
		assists_modifier_label.size.x = size.x
		assists_modifier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		assists_modifier_label.global_position = Vector2(0, roll_value_label.global_position.y + 100)
		assists_modifier_label.text = "+" + str(curr_assists) + " assist" + ("s" if curr_assists > 1 else "")
		add_child(assists_modifier_label)
		# Combine assists with roll value
		var assists_modifier_tween = create_tween()
		assists_modifier_tween.tween_property(assists_modifier_label, "global_position:y", roll_value_label.global_position.y + 10, 0.25).set_delay(0.5)
		var cb = Callable(self, "combine_assists_modifier").bind(curr_assists)
		assists_modifier_tween.finished.connect(cb)
	else:
		calc_complete.emit()

func combine_hot_or_cold_bonus(bonus: int):
	var new_roll_value = int(roll_value_label.text) + bonus
	roll_value_label.text = str(new_roll_value)
	hot_cold_modifier_label.queue_free()
	calc_complete.emit()

func add_hot_or_cold_modifiers():
	var offensive_player = get_off_player_card()
	var marker = offensive_player.marker
	if marker.curr_marker_count > 0:
		var bonus_amt = 4 * marker.curr_marker_count
		bonus_amt = -bonus_amt if marker.curr_marker_type == Marker.MarkerType.COLD else bonus_amt
		var modifier_label_text = "(hot)" if marker.curr_marker_type == Marker.MarkerType.HOT else "(cold)"
		hot_cold_modifier_label = Label.new()
		hot_cold_modifier_label.add_theme_font_size_override("font_size", 30)
		hot_cold_modifier_label.size.x = size.x
		hot_cold_modifier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hot_cold_modifier_label.global_position = Vector2(0, roll_value_label.global_position.y + 100)
		hot_cold_modifier_label.text = ("+" if bonus_amt > 0 else "") + str(bonus_amt) + " " + modifier_label_text
		add_child(hot_cold_modifier_label)
		# Combine hot/cold bonus with roll value
		var hot_cold_modifier_label_tween = create_tween()
		hot_cold_modifier_label_tween.tween_property(hot_cold_modifier_label, "global_position:y", roll_value_label.global_position.y + 10, 0.25).set_delay(0.75)
		var cb = Callable(self, "combine_hot_or_cold_bonus").bind(bonus_amt)
		hot_cold_modifier_label_tween.finished.connect(cb)
	else:
		calc_complete.emit()

func get_off_stat(bp_card: BallPlayerCard):
	return int(bp_card.offense_value.text)

func get_def_stat(bp_card: BallPlayerCard):
	return int(bp_card.defense_value.text)

func handle_off_modifier():
	var off_stat = get_off_stat(player_card) if offense_side == Game.Side.PLAYER else get_off_stat(cpu_card)
	var def_stat = get_def_stat(cpu_card) if offense_side == Game.Side.PLAYER else get_def_stat(player_card)
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
		off_modifier_tween.tween_property(off_modifier_label, "global_position:y", roll_value_label.global_position.y + 10, 0.25).set_delay(0.5)
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
	var offense_bp_card = get_off_player_card()
	offense_bp_card.animation_player.animation_finished.connect(on_anim_finished)
	offense_bp_card.animation_player.play("highlight_offense_stat")

func highlight_def_stat():
	var defense_bp_card = get_def_player_card()
	defense_bp_card.animation_player.animation_finished.connect(on_anim_finished)
	defense_bp_card.animation_player.play("highlight_defense_stat")

func reset_stat_highlight():
	var defense_bp_card = get_def_player_card()
	var offense_bp_card = get_off_player_card()
	defense_bp_card.animation_player.animation_finished.disconnect(on_anim_finished) 	# prevent double firing of calc complete event
	offense_bp_card.animation_player.play_backwards("highlight_offense_stat")
	defense_bp_card.animation_player.play_backwards("highlight_defense_stat")

func on_anim_finished(anim_name: String):
	if anim_name == "highlight_offense_stat" or anim_name == "highlight_defense_stat":
		go_to_next_step_generic()

func get_table_row_for_roll_value():
	var roll_value = clamp(int(roll_value_label.text), 1, 30)
	var roll_table_row
	var offense_bp_card = get_off_player_card()
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
	hl_row_range.tween_property(roll_range_label.label, "theme_override_font_sizes/font_size", 25, 0.4)
	hl_row_range.finished.connect(go_to_next_step_generic)

func dehighlight_roll_table_row():
	var roll_table_row = get_table_row_for_roll_value()
	var roll_range_label = roll_table_row["roll_range_label"] as TableValue
	var hl_row_range = create_tween()
	hl_row_range.tween_property(roll_range_label.label, "theme_override_font_sizes/font_size", 15, 0.4)
	hl_row_range.finished.connect(go_to_next_step_generic)

func push_roll_value_up():
	var tween = create_tween()
	var start_y = roll_value_label.global_position.y
	tween.tween_property(roll_value_label, "theme_override_font_sizes/font_size", 30, 0.25)
	var shrink_fn = func shrink_roll_value():
		var new_tween = create_tween()
		var end_y = roll_value_label.global_position.y - 100
		new_tween.tween_property(roll_value_label, "global_position:y", end_y, 0.25)
		new_tween.finished.connect(go_to_next_step_generic)
	tween.finished.connect(shrink_fn)
	matchup_score = matchup_pts_assts_rebs_scene.instantiate()
	add_child(matchup_score)
	matchup_score.global_position = Vector2(508, get_viewport_rect().size.y + 200)
	var tween_slide = create_tween()
	tween_slide.tween_property(matchup_score, "global_position:y", start_y, 1.0)

func go_to_next_step_generic():
	calc_complete.emit()

func handle_point_tally_anim(points_scored_value: int, bonus_modifier: String = ""):
	var points_value = matchup_score.points_value
	var points_bonus_label = Label.new()
	add_child(points_bonus_label)
	points_bonus_label.text = bonus_modifier + ("+" if points_scored_value >= 0 else "") + str(points_scored_value)
	points_bonus_label.global_position = Vector2(points_value.global_position.x, points_value.global_position.y + 75)
	points_bonus_label.add_theme_font_size_override("font_size", 50)
	points_bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var add_points_bonus_tween = create_tween()
	add_points_bonus_tween.tween_property(points_bonus_label, "global_position:y", points_value.global_position.y, 0.25).set_delay(0.5)
	var on_combine_finished = func on_combine_finished():
		var tween = create_tween()
		tween.tween_property(points_value, "theme_override_font_sizes/font_size", 50, 0.25)
		calc_complete.emit()
	var combine_fn = func combine_with_total_points():
		var tween = create_tween()
		points_bonus_label.queue_free()
		points_value.text = str(max(0, int(points_value.text) + points_scored_value))
		tween.tween_property(points_value, "theme_override_font_sizes/font_size", 60, 0.25)
		tween.finished.connect(on_combine_finished)
	add_points_bonus_tween.finished.connect(combine_fn)
	
func tally_points():
	var roll_table_row = get_table_row_for_roll_value()
	var points_scored = roll_table_row["points_label"] as TableValue
	var points_value = 0 if points_scored.label.text == "" else int(points_scored.label.text)
	if points_value == 0:
		calc_complete.emit()
	else:
		var hl_points_scored = create_tween()
		hl_points_scored.tween_property(points_scored.label, "theme_override_font_sizes/font_size", 25, 0.25)
		handle_point_tally_anim(points_value)

func tally_strat_bonus_points():
	if strategy_point_bonuses == 0:
		calc_complete.emit()
	else:
		handle_point_tally_anim(strategy_point_bonuses)

func handle_assist_tally_anim(assist_value: int, bonus_modifier: String = ""):
	var assists_value = matchup_score.assists_value
	var assists_bonus_label = Label.new()
	add_child(assists_bonus_label)
	assists_bonus_label.text = bonus_modifier + "+" + str(assist_value)
	assists_bonus_label.global_position = Vector2(assists_value.global_position.x, assists_value.global_position.y + 75)
	assists_bonus_label.add_theme_font_size_override("font_size", 50)
	assists_bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var add_assists_bonus_tween = create_tween()
	add_assists_bonus_tween.tween_property(assists_bonus_label, "global_position:y", assists_value.global_position.y, 0.25).set_delay(0.5)
	var on_combine_finished = func on_combine_finished():
		var tween = create_tween()
		tween.tween_property(assists_value, "theme_override_font_sizes/font_size", 50, 0.25)
		calc_complete.emit()
	var combine_fn = func combine_with_total_points():
		var tween = create_tween()
		assists_bonus_label.queue_free()
		assists_value.text = str(int(assists_value.text) + assist_value)
		tween.tween_property(assists_value, "theme_override_font_sizes/font_size", 60, 0.25)
		tween.finished.connect(on_combine_finished)
	add_assists_bonus_tween.finished.connect(combine_fn)

func tally_assists():
	var roll_table_row = get_table_row_for_roll_value()
	var assists_made = roll_table_row["assists_label"] as TableValue
	var ast_value = 0 if assists_made.label.text == "" else int(assists_made.label.text)
	if ast_value == 0:
		calc_complete.emit()
	else:
		var hl_assists_scored = create_tween()
		hl_assists_scored.tween_property(assists_made.label, "theme_override_font_sizes/font_size", 25, 0.25)
		handle_assist_tally_anim(ast_value)

func tally_strat_bonus_assists():
	if strategy_assist_bonuses == 0:
		calc_complete.emit()
	else:
		handle_assist_tally_anim(strategy_assist_bonuses)

func tally_rebounds():
	var roll_table_row = get_table_row_for_roll_value()
	var rebounds_grabbed = roll_table_row["rebounds_label"] as TableValue
	var reb_value = 0 if rebounds_grabbed.label.text == "" else int(rebounds_grabbed.label.text)
	if reb_value == 0:
		calc_complete.emit()
	else:
		var hl_rebounds_grabbed = create_tween()
		hl_rebounds_grabbed.tween_property(rebounds_grabbed.label, "theme_override_font_sizes/font_size", 25, 0.25)
		handle_rebound_tally_anim(reb_value)

func tally_strat_bonus_rebounds():
	if strategy_rebound_bonuses == 0:
		calc_complete.emit()
	else:
		handle_rebound_tally_anim(strategy_rebound_bonuses)

func handle_rebound_tally_anim(num_rebounds: int):
	var rebounds_value = matchup_score.rebounds_value
	var rebounds_bonus_label = Label.new()
	add_child(rebounds_bonus_label)
	var prefix = "+" if num_rebounds >= 0 else ""
	rebounds_bonus_label.text = prefix + str(num_rebounds)
	rebounds_bonus_label.global_position = Vector2(rebounds_value.global_position.x, rebounds_value.global_position.y + 75)
	rebounds_bonus_label.add_theme_font_size_override("font_size", 50)
	rebounds_bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var add_rebounds_bonus_tween = create_tween()
	add_rebounds_bonus_tween.tween_property(rebounds_bonus_label, "global_position:y", rebounds_value.global_position.y, 0.25).set_delay(0.5)
	var on_combine_finished = func on_combine_finished():
		var tween = create_tween()
		tween.tween_property(rebounds_value, "theme_override_font_sizes/font_size", 50, 0.25)
		calc_complete.emit()
	var combine_fn = func combine_with_total_points():
		var tween = create_tween()
		rebounds_bonus_label.queue_free()
		rebounds_value.text = str(max(0, int(rebounds_value.text) + num_rebounds))
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
	tween.tween_property(roll_range_label.label, "theme_override_font_sizes/font_size", 15, 0.25)
	tween.parallel().tween_property(rebounds_value_row.label, "theme_override_font_sizes/font_size", 15, 0.25)
	tween.parallel().tween_property(assists_value_row.label, "theme_override_font_sizes/font_size", 15, 0.25)
	tween.parallel().tween_property(points_value_row.label, "theme_override_font_sizes/font_size", 15, 0.25)
	var on_continue_button = Button.new()
	on_continue_button.text = "Continue"
	add_child(on_continue_button)
	on_continue_button.add_theme_font_size_override("font_size", 20)
	on_continue_button.global_position.y = matchup_score.points_value.global_position.y + 90
	on_continue_button.global_position.x = matchup_score.assists_value.global_position.x
	on_continue_button.pressed.connect(on_matchup_completed)

func on_matchup_completed():
	var all_stats = matchup_score.get_all_stats()
	var assists_used = curr_assists if use_assists_checkbox.button_pressed else 0
	matchup_complete.emit(all_stats, offense_side, assists_used)
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

func enable_use_assists():
	use_assists_checkbox.button_pressed = true

func get_off_player_card() -> BallPlayerCard:
	return player_card if offense_side == Game.Side.PLAYER else cpu_card

func get_def_player_card() -> BallPlayerCard:
	return cpu_card if offense_side == Game.Side.PLAYER else player_card

func show_strategy_card_selector():
	use_strategy_card_button.hide()
	roll_button.hide()
	use_assists_checkbox.hide()
	var on_finished = func _on_finished():
		did_use_strategy_card = true
		strategy_card_selector.queue_free()
		use_strategy_card_button.hide()
	var on_close = func _on_close():
		strategy_card_selector.queue_free()
		roll_button.show()
		use_strategy_card_button.show()
		if offense_side == Game.Side.PLAYER:
			did_use_strategy_card = false
			if curr_assists > 0:
				use_assists_checkbox.show()
		else:
			# If the Player is on defense and closes the strategy card selector without using a card, 
			# set the flag to false (Not sure if we actually need this since we never set it to true?)
			did_opp_use_def_strategy_card = false
	strategy_card_selector = strategy_card_selector_scene.instantiate() as StrategyCardSelector
	strategy_card_selector.off_player = get_off_player_card()
	strategy_card_selector.def_player = get_def_player_card()
	strategy_card_selector.matchup_container = self
	add_child(strategy_card_selector)
	strategy_card_selector.on_finished.connect(on_finished)
	strategy_card_selector.on_close.connect(on_close)
	var team = game.player_team if offense_side == Game.Side.PLAYER else game.cpu_team
	if team.strategy_card_deck != null:
		strategy_card_selector.on_strategy_card_selected.connect(team.strategy_card_deck.on_strategy_card_selected)

func get_on_process_strategy_complete_callable(strategy_type: StrategyCardConfig.StrategyCardType):
	if strategy_type == StrategyCardConfig.StrategyCardType.DEFENSE:
		if offense_side == Game.Side.PLAYER:
			return "on_process_cpu_def_strategy_complete"
		else:
			return "on_process_player_def_strategy_complete"
	elif strategy_type == StrategyCardConfig.StrategyCardType.OFFENSE:
		if offense_side == Game.Side.PLAYER:
			return "on_process_player_off_strategy_complete"
		else:
			return "on_process_cpu_off_strategy_complete"

func apply_single_bonus(bonus, strategy_type, custom_cb):
	var off_player = get_off_player_card()
	var def_player = get_def_player_card()
	match (bonus.bonus_type):
		StrategyCardBonusNode.BonusType.STAT:
			var stat_bonus = bonus as StatBonus
			var player_to_apply_bonus_to = def_player if strategy_type == StrategyCardConfig.StrategyCardType.DEFENSE else off_player
			if !stat_bonus_animator.on_complete.has_connections():
				stat_bonus_animator.on_complete.connect(custom_cb)
			stat_bonus_animator.apply_bonus_to_player(stat_bonus.off_bonus_amount, stat_bonus.def_bonus_amount, player_to_apply_bonus_to)
		StrategyCardBonusNode.BonusType.MARKER:
			var marker_bonus = bonus as MarkerBonus
			if !marker_bonus_animator.on_complete.has_connections():
				marker_bonus_animator.on_complete.connect(custom_cb)
			marker_bonus_animator.apply_bonus_to_player(off_player, def_player, marker_bonus)
		StrategyCardBonusNode.BonusType.ROLL:
			var roll_bonus = bonus as RollBonus
			strategy_roll_bonuses += roll_bonus.roll_bonus_amount
			custom_cb.call()
		StrategyCardBonusNode.BonusType.BOX_SCORE:
			var box_score_bonus = bonus as BoxScoreBonus
			if box_score_bonus.target_side == BoxScoreBonus.TargetSide.OFFENSE:
				if box_score_bonus.bonus_stat_type == BoxScoreBonus.StatType.POINTS:
					strategy_point_bonuses += box_score_bonus.bonus_amt
				elif box_score_bonus.bonus_stat_type == BoxScoreBonus.StatType.REBOUNDS:
					strategy_rebound_bonuses += box_score_bonus.bonus_amt
				elif box_score_bonus.bonus_stat_type == BoxScoreBonus.StatType.ASSISTS:
					strategy_assist_bonuses += box_score_bonus.bonus_amt
				custom_cb.call()
			else:
				# If the target of this bonus is the defender and the current offensive player card is the player, then it was
				# the CPU that used the defensive strategy card resulting in this bonus
				var is_cpu = offense_side == Game.Side.PLAYER
				box_score_bonus_animator.animate_box_score_bonus(box_score_bonus, is_cpu)
				var on_box_score_anim_finished = func _on_anim_finished():
					var side_to_receive_bonus = Game.Side.CPU if is_cpu else Game.Side.PLAYER
					game.add_box_score_bonuses(side_to_receive_bonus, box_score_bonus.bonus_stat_type, box_score_bonus.bonus_amt)
					custom_cb.call()
					box_score_bonus_animator.hide()
				box_score_bonus_animator.show()
				if !box_score_bonus_animator.on_box_score_bonus_complete.has_connections():
					box_score_bonus_animator.on_box_score_bonus_complete.connect(on_box_score_anim_finished)
		StrategyCardBonusNode.BonusType.NOOP:
			custom_cb.call()

func on_strategy_card_processing_complete(strategy_type: StrategyCardConfig.StrategyCardType):
	if strategy_type == StrategyCardConfig.StrategyCardType.DEFENSE:
		did_opp_use_def_strategy_card = true
	var on_complete_callable = Callable(self, get_on_process_strategy_complete_callable(strategy_type))
	on_complete_callable.call()

func init_cpu_roll():
	roll_button.hide()
	close_button.hide()
	use_assists_checkbox.hide()
	use_strategy_card_button.hide()
