class_name StrategyCard
extends Control

@export var strategy_card_config: StrategyCardConfig
@onready var description_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/CardDescription
@onready var name_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/CardName
@onready var type_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/CardType
@onready var button: Button = $Panel/Button

signal on_card_selected

# Called when the node enters the scene tree for the first time.
func _ready():
	description_label.text = strategy_card_config.card_description
	name_label.text = strategy_card_config.card_name
	type_label.text = "Offense" if strategy_card_config.strategy_type == StrategyCardConfig.StrategyCardType.OFFENSE else "Defense"
	button.pressed.connect(on_card_click)

func on_card_click():
	print(self)
	on_card_selected.emit(self)
