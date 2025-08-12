class_name StrategyBonuses
extends Panel

@export var strategy_bonus_line_scene: PackedScene
@onready var failure_label: Label = $FailureLabel
@onready var title_label: Label = $Label
@onready var container = $MarginContainer/ScrollContainer/VBoxContainer
@onready var continue_button = $Button

signal on_close

func _ready():
	continue_button.pressed.connect(handle_close)

func add_bonus_line(attr_name: String, bonus_amt: int):
	var strategy_bonus_line = strategy_bonus_line_scene.instantiate() as StrategyCardBonusLine
	container.add_child(strategy_bonus_line)
	strategy_bonus_line.setup(attr_name, bonus_amt)

func handle_close():
	hide()
	on_close.emit()

func show_failure_message():
	title_label.hide()
	failure_label.show()