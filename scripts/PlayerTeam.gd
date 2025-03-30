class_name PlayerTeam
extends Node

@export var starting_lineup_scene: PackedScene
@export var lineup_selector_scene: PackedScene
@export var starting_lineup_wrapper: VBoxContainer

var starting_lineup: StartingLineup
var lineup_selector: LineupSelector

func _ready():
	if starting_lineup_wrapper != null:
		lineup_selector = lineup_selector_scene.instantiate() as LineupSelector
		starting_lineup_wrapper.add_child(lineup_selector)
