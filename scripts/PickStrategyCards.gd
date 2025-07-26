class_name PickStrategyCards
extends Control

@onready var selected_cards_container = $VBoxContainer/MarginContainer/ScrollContainer/SelectedCardsContainer
@onready var available_cards_container = $VBoxContainer/MarginContainer2/ScrollContainer/AvailableCardsContainer
@onready var continue_button = $Continue as Button
@export var strategy_card_scene: PackedScene
var selected_strategy_card
var num_cards_to_choose_from := 5
const MAX_CARDS_TO_PICK := 3

func _ready() -> void:
	var all_configs = []
	for strategy_name in SceneVariables.all_strategy_card_names:
		var strategy_card_config = load("res://resources/strategy/" + strategy_name + ".tres") as StrategyCardConfig
		all_configs.append(strategy_card_config)
	for i in range(0, num_cards_to_choose_from):
		var strategy_card = strategy_card_scene.instantiate() as StrategyCard
		strategy_card.strategy_card_config = all_configs.pick_random()
		strategy_card.config_id = i
		var on_select_callable = Callable(self, "add_strategy_card").bind(strategy_card)
		available_cards_container.add_child(strategy_card)
		strategy_card.button.pressed.connect(on_select_callable)
	continue_button.pressed.connect(go_to_game_scene)

func add_strategy_card(selected_card: StrategyCard):
	if selected_cards_container.get_children().has(selected_card):
		selected_cards_container.remove_child(selected_card)
		available_cards_container.add_child(selected_card)
	elif selected_cards_container.get_child_count() < MAX_CARDS_TO_PICK:
		available_cards_container.remove_child(selected_card)
		selected_cards_container.add_child(selected_card)
	if selected_cards_container.get_child_count() == MAX_CARDS_TO_PICK:
		continue_button.show()

func go_to_game_scene():
	SceneVariables.player_strategy_card_deck = selected_cards_container.get_children().map(func (c): return c.strategy_card_config)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
