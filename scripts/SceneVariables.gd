extends Node

enum BudgetTier {
	LOW,
	MED,
	HIGH
}

var quarter_scores = {}
var full_cpu_scorer_statlines = {}
var full_player_scorer_statlines = {}
var player_score := 0
var cpu_score := 0
var player_team_bp_configs := {}
var budget_tier := BudgetTier.LOW