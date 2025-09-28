class_name GameOver
extends Node2D

@onready var button = $CanvasLayer/Button as Button
@onready var games_won_label = $CanvasLayer/GamesWonLabel as Label

func _ready() -> void:
	games_won_label.text = "Games Won: " + str(SceneVariables.num_games_won)
	button.pressed.connect(on_continue)

func on_continue():
	SceneVariables.reset_player_data()
	get_tree().change_scene_to_file("res://scenes/DraftScene.tscn")