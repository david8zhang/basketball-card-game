class_name CPUTeam
extends Node

@export var starting_lineup_scene: PackedScene
@export var starting_lineup_wrapper: VBoxContainer

var starting_lineup: StartingLineup

func _ready():
	if starting_lineup_wrapper != null:
		starting_lineup = starting_lineup_scene.instantiate() as StartingLineup
		starting_lineup_wrapper.add_child(starting_lineup)
		starting_lineup.init_cards()