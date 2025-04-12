class_name Game
extends Node2D

enum Side {
	PLAYER,
	CPU
}

var all_player_stats = {}
var selected_player_bp_card: BallPlayerCard
var selected_cpu_bp_card: BallPlayerCard

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
var matchup_container: MatchupContainer

# Called when the node enters the scene tree for the first time.
func _init():
	for file_name in DirAccess.get_files_at("res://resources"):
		if (file_name.get_extension() == "tres"):
			var stat_config = load("res://resources/" + file_name) as BallPlayerStats
			for p in stat_config.positions:
				if p not in all_player_stats:
					all_player_stats[p] = []
				all_player_stats[p].append(stat_config)

func assemble_random_lineup() -> Dictionary:
	var pos_to_player_map = {}
	var positions = all_player_stats.keys()
	positions.sort()
	for pos in positions:
		var players_to_pick_from = all_player_stats[pos].filter(func(p): return !pos_to_player_map.has(p))
		var random_player_stat = players_to_pick_from.pick_random() as BallPlayerStats
		pos_to_player_map[pos] = random_player_stat
	return pos_to_player_map

func player_select_card_to_score_with(card: BallPlayerCard):
	selected_player_bp_card = card
	var opp_matchup_bp_card = cpu_team.get_card_at_position(selected_player_bp_card.get_assigned_position())
	matchup_container = matchup_container_scene.instantiate() as MatchupContainer
	canvas_layer.add_child(matchup_container)
	matchup_container.set_player_card(card)
	matchup_container.set_cpu_card(opp_matchup_bp_card)
	matchup_container.set_offense_side(Side.PLAYER)
	matchup_container.matchup_complete.connect(add_stats_from_matchup)
	matchup_container.show()

func add_stats_from_matchup(all_stats: Dictionary, side: Side):
	if side == Side.PLAYER:
		player_score_label.text = str(int(player_score_label.text) + all_stats["points"])
		player_assists_label.text = "A: " + str(int(player_assists_label.text) + all_stats["assists"])
		player_rebounds_label.text = "R: " + str(int(player_rebounds_label.text) + all_stats["rebounds"])
	elif side == Side.CPU:
		cpu_score_label.text = str(int(cpu_score_label.text) + all_stats["points"])
		cpu_assists_label.text = "A: " + str(int(cpu_assists_label.text) + all_stats["asists"])
		cpu_rebounds_label.text = "R: " + str(int(cpu_rebounds_label.text) + all_stats["rebounds"])
