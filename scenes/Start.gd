class_name Start
extends Node2D

@onready var button = $CanvasLayer/Button as Button

func _ready() -> void:
	var on_play = func _on_play():
		get_tree().change_scene_to_file("res://scenes/DraftScene.tscn")
	button.pressed.connect(on_play)
