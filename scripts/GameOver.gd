class_name GameOver
extends Node2D

@onready var button = $CanvasLayer/Button as Button

func _ready() -> void:
	button.pressed.connect(on_continue)

func on_continue():
	SceneVariables.reset_player_data()
	get_tree().change_scene_to_file("res://scenes/DraftScene.tscn")
