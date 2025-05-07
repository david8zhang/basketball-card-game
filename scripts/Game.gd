class_name Game
extends Node2D

enum Side {
	PLAYER,
	CPU
}

var all_player_stats = {}
var selected_player_bp_card: BallPlayerCard
var selected_cpu_bp_card: BallPlayerCard

var player_completed_scorer_positions = []
var full_player_scorer_statlines = {}
var cpu_completed_scorer_positions = []
var full_cpu_scorer_statlines = {}

@onready var player_team: PlayerTeam = $PlayerTeam as PlayerTeam
@onready var cpu_team: CPUTeam = $CPUTeam as CPUTeam
@onready var canvas_layer: CanvasLayer = $CanvasLayer as CanvasLayer
@onready var player_score_label = $CanvasLayer/Scoreboard/PlayerScore as Label
@onready var player_assists_label = $CanvasLayer/Scoreboard/PlayerAssists as Label
@onready var player_rebounds_label = $CanvasLayer/Scoreboard/PlayerRebounds as Label
@onready var cpu_score_label = $CanvasLayer/Scoreboard/CPUScore as Label
@onready var cpu_assists_label = $CanvasLayer/Scoreboard/CPUAssists as Label
@onready var cpu_rebounds_label = $CanvasLayer/Scoreboard/CPURebounds as Label

@export var matchup_container_scene: PackedScene
@export var quarter_end_modal_scene: PackedScene

var matchup_container: MatchupContainer
var quarter_end_modal: QuarterEnd
var quarter_number: int = 1
var quarter_scores = {}

class BoxScoreStatLine:
	var bp_card: BallPlayerCard
	var points: int
	var assists: int
	var rebounds: int

	func _init(_bp_card: BallPlayerCard, _points: int, _assists: int, _rebounds: int):
		bp_card = _bp_card
		points = _points
		assists = _assists
		rebounds = _rebounds

# Called when the node enters the scene tree for the first time.
func _init():
	for file_name in DirAccess.get_files_at("res://resources"):
		if (file_name.get_extension() == "tres"):
			var stat_config = load("res://resources/" + file_name) as BallPlayerStats
			for p in stat_config.positions:
				if p not in all_player_stats:
					all_player_stats[p] = []
				all_player_stats[p].append(stat_config)

func _ready():
	get_rebounds(player_rebounds_label)

func assemble_random_lineup() -> Dictionary:
	var pos_to_player_map = {}
	var picked_players = []
	var positions = all_player_stats.keys()
	positions.sort()

	var remove_invalid_players = func (p):
		var player_name = p.first_name + " " + p.last_name
		return !pos_to_player_map.values().has(p) and !picked_players.has(player_name)
	
	for pos in positions:
		var players_to_pick_from = all_player_stats[pos].filter(remove_invalid_players)
		var random_player_stat = players_to_pick_from.pick_random() as BallPlayerStats
		pos_to_player_map[pos] = random_player_stat
		picked_players.append(random_player_stat.first_name + " " + random_player_stat.last_name)
	return pos_to_player_map

func player_select_card_to_score_with(card: BallPlayerCard):
	if !player_completed_scorer_positions.has(card.get_assigned_position()):
		selected_player_bp_card = card
		var opp_matchup_bp_card = cpu_team.get_card_at_position(selected_player_bp_card.get_assigned_position())
		matchup_container = matchup_container_scene.instantiate() as MatchupContainer
		canvas_layer.add_child(matchup_container)
		matchup_container.set_player_card(card)
		matchup_container.set_cpu_card(opp_matchup_bp_card)
		matchup_container.set_offense_side(Side.PLAYER)
		matchup_container.matchup_complete.connect(on_matchup_complete)
		matchup_container.show()

func cpu_select_card_to_score_with():
	var cpu_cards = cpu_team.starting_lineup.starting_lineup_cards
	var cards_to_score_with = cpu_cards.filter(func(c): return !cpu_completed_scorer_positions.has(c.get_assigned_position()))
	selected_cpu_bp_card = cards_to_score_with.pick_random()
	
	# Play a little animation indicating a card was chosen
	var on_zoom_out_finished = func():
		var opp_matchup_bp_card = player_team.get_card_at_position(selected_cpu_bp_card.get_assigned_position())
		matchup_container = matchup_container_scene.instantiate() as MatchupContainer
		canvas_layer.add_child(matchup_container)
		matchup_container.set_player_card(opp_matchup_bp_card)
		matchup_container.set_cpu_card(selected_cpu_bp_card)
		matchup_container.set_offense_side(Side.CPU)
		matchup_container.matchup_complete.connect(on_matchup_complete)
		matchup_container.show()
		matchup_container.on_roll()
		matchup_container.hide_close_button()

	var on_hold_finished = func():
		var zoom_out_card = create_tween()
		zoom_out_card.tween_property(selected_cpu_bp_card, "scale", Vector2(1, 1), 0.25)
		zoom_out_card.finished.connect(on_zoom_out_finished)

	var on_zoomed = func():
		var zoom_hold_timer = Timer.new()
		zoom_hold_timer.wait_time = 1.0
		zoom_hold_timer.autostart = true
		zoom_hold_timer.one_shot = true
		zoom_hold_timer.timeout.connect(on_hold_finished)
		add_child(zoom_hold_timer)

	var zoom_in_card = create_tween()
	zoom_in_card.tween_property(selected_cpu_bp_card, "scale", Vector2(1.05, 1.05), 0.25)
	zoom_in_card.finished.connect(on_zoomed)

func on_matchup_complete(all_stats: Dictionary, side: Side):
	add_stats_from_matchup(all_stats, side)
	if is_quarter_completed():
		if quarter_number == 4:
			SceneVariables.quarter_scores = quarter_scores
			SceneVariables.full_cpu_scorer_statlines = full_cpu_scorer_statlines
			get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
		else:
			quarter_end_modal = quarter_end_modal_scene.instantiate() as QuarterEnd
			canvas_layer.add_child(quarter_end_modal)
			quarter_end_modal.update_scores(get_player_score(), get_cpu_score())
			quarter_end_modal.update_player_box_score(full_player_scorer_statlines)
			quarter_end_modal.update_cpu_box_score(full_cpu_scorer_statlines)
			quarter_end_modal.update_quarter_number(quarter_number)
			var callable = Callable(self, "on_new_quarter_start")
			quarter_end_modal.continue_button.pressed.connect(callable)
	elif side == Side.PLAYER:
		cpu_select_card_to_score_with()

func is_quarter_completed():
	var player_lineup_cards = player_team.get_starting_cards()
	var cpu_lineup_cards = cpu_team.get_starting_cards()
	return player_lineup_cards.size() == player_completed_scorer_positions.size() and \
		cpu_lineup_cards.size() == cpu_completed_scorer_positions.size()

func get_player_score():
	return int(player_score_label.text)

func get_cpu_score():
	return int(cpu_score_label.text)

func get_rebounds(rebounds_label: Label) -> int:
	var rebounds_value = rebounds_label.text.split(": ")
	if rebounds_value.size() > 1:
		return int(rebounds_value[1])
	return 0

func get_assists(assists_label: Label) -> int:
	var assists_value = assists_label.text.split(": ")
	if assists_value.size() > 1:
		return int(assists_value[1])
	return 0

func add_stats_from_matchup(all_stats: Dictionary, side: Side):
	if side == Side.PLAYER:
		var stat_line = BoxScoreStatLine.new(selected_player_bp_card, all_stats["points"], all_stats["assists"], all_stats["rebounds"])
		update_statlines(selected_player_bp_card.full_name(), stat_line, full_player_scorer_statlines)
		player_completed_scorer_positions.append(selected_player_bp_card.get_assigned_position())
		selected_player_bp_card.button.flat = false
		player_score_label.text = str(int(player_score_label.text) + all_stats["points"])
		player_assists_label.text = "A: " + str(get_assists(player_assists_label) + all_stats["assists"])
		player_rebounds_label.text = "R: " + str(get_rebounds(player_rebounds_label) + all_stats["rebounds"])
	elif side == Side.CPU:
		var stat_line = BoxScoreStatLine.new(selected_cpu_bp_card, all_stats["points"], all_stats["assists"], all_stats["rebounds"])
		update_statlines(selected_cpu_bp_card.full_name(), stat_line, full_cpu_scorer_statlines)
		cpu_completed_scorer_positions.append(selected_cpu_bp_card.get_assigned_position())
		selected_cpu_bp_card.button.flat = false
		cpu_score_label.text = str(int(cpu_score_label.text) + all_stats["points"])
		cpu_assists_label.text = "A: " + str(get_assists(cpu_assists_label) + all_stats["assists"])
		cpu_rebounds_label.text = "R: " + str(get_rebounds(cpu_rebounds_label) + all_stats["rebounds"])

func update_statlines(full_name: String, stat_line: BoxScoreStatLine, scorer_statline: Dictionary):
	if scorer_statline.has(full_name):
		var stat_line_to_update = scorer_statline[full_name] as BoxScoreStatLine
		stat_line_to_update.points += stat_line.points
		stat_line_to_update.assists += stat_line.assists
		stat_line_to_update.rebounds += stat_line.rebounds
	else:
		scorer_statline[full_name] = stat_line

func on_new_quarter_start():
	quarter_number += 1
	player_completed_scorer_positions = []
	cpu_completed_scorer_positions = []
	quarter_end_modal.queue_free()
	for card in player_team.get_starting_cards():
		card.button.flat = true
	for card in cpu_team.get_starting_cards():
		card.button.flat = true