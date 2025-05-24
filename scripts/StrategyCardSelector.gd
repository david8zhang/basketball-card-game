class_name StrategyCardSelector
extends Control

@export var strategy_card_scene: PackedScene
@onready var card_container: HBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer
@onready var close_button: Button = $CloseButton

signal on_close

func _ready():
    close_button.pressed.connect(on_close_selector)

func on_close_selector():
    on_close.emit()