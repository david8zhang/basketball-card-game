class_name PlayerTeam
extends Node

@onready var game = get_node("/root/Main") as Game
@export var starting_lineup_scene: PackedScene
@export var lineup_selector_scene: PackedScene
@export var starting_lineup_wrapper: VBoxContainer

var starting_lineup: StartingLineup
var lineup_selector: LineupSelector

func _ready():
	if starting_lineup_wrapper != null:
		starting_lineup = starting_lineup_scene.instantiate() as StartingLineup
		starting_lineup_wrapper.add_child(starting_lineup)
		var random_lineup = game.assemble_random_lineup()
		starting_lineup.init_cards(random_lineup)
