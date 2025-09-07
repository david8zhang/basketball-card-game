class_name TeamConfig
extends Resource

@export var team_name: String
@export var team_logo: Texture2D

@export_group("Starting Lineup")
@export var starting_pg: BallPlayerStats
@export var starting_sg: BallPlayerStats
@export var starting_sf: BallPlayerStats
@export var starting_pf: BallPlayerStats
@export var starting_c: BallPlayerStats

@export_group("Bench")
@export var bench_players: Array[BallPlayerStats]