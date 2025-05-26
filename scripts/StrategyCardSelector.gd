class_name StrategyCardSelector
extends Control

@export var strategy_card_scene: PackedScene
@onready var card_container: HBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/HBoxContainer
@onready var close_button: Button = $CloseButton

var off_player: BallPlayerCard
var def_player: BallPlayerCard
var all_strategy_card_configs = []
var strategy_cards = []
const NUM_STRATEGY_CARDS = 3

signal on_close

func _init():
	for file_name in DirAccess.get_files_at("res://resources/strategy"):
		if (file_name.get_extension() == "tres"):
			var strategy_card_config = load("res://resources/strategy/" + file_name) as StrategyCardConfig
			all_strategy_card_configs.append(strategy_card_config)

func _ready():
	close_button.pressed.connect(on_close_selector)
	for i in range(0, NUM_STRATEGY_CARDS):
		var strategy_card = strategy_card_scene.instantiate() as StrategyCard
		var random_config = all_strategy_card_configs.pick_random()
		strategy_card.strategy_card_config = random_config
		strategy_card.on_card_selected.connect(select_strategy_card)
		card_container.add_child(strategy_card)

func select_strategy_card(sc: StrategyCard):
	var condition_bonus_result = sc.strategy_card_config.process(off_player, def_player)
	on_close_selector()

func on_close_selector():
	on_close.emit()
