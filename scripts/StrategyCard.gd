class_name StrategyCard
extends Control

@export var strategy_card_config: StrategyCardConfig
@onready var description_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/CardDescription
@onready var name_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/HBoxContainer/CardName
@onready var type_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/CardType
@onready var button: Button = $Panel/Button

# Config ID in order to associate this card with a config in deck
var config_id := 0

signal on_clicked(strategy_card)

# Called when the node enters the scene tree for the first time.
func _ready():
	description_label.text = strategy_card_config.card_description
	name_label.text = strategy_card_config.card_name
	type_label.text = "Offense" if strategy_card_config.strategy_type == StrategyCardConfig.StrategyCardType.OFFENSE else "Defense"
	button.pressed.connect(on_selected)

func get_strategy_name():
	return name_label.text

func on_selected():
	on_clicked.emit(self)