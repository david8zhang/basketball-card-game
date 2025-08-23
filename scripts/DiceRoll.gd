class_name DiceRoll
extends Panel

@onready var container = $VBoxContainer as VBoxContainer
@onready var roll_value_label: Label = $VBoxContainer/RollValue
@onready var button: Button = $VBoxContainer/Button

# Exported timing variables (tweakable in Inspector)
@export var bonus_tween_duration: float = 0.25
@export var bonus_tween_delay: float = 0.25
@export var scramble_wait_time: float = 0.075

var curr_threshold: int
var curr_result_type: StrategyCardNode.NodeResultType
var dice_type: int

var static_bonus: int
var three_point_bonus: int

signal on_roll_complete

func _ready():
	button.hide()
	button.pressed.connect(complete_roll)

func configure_dice_roll(condition_ref: RollDiceAction):
	dice_type = condition_ref.dice_type
	static_bonus = condition_ref.static_bonus
	three_point_bonus = condition_ref.three_point_bonus

func roll_value(value_to_roll: int):
	scramble_numbers(15, null, value_to_roll)

func add_roll_bonus(bonus_amt: int, tag: String, on_complete: Callable):
	var label = Label.new()
	container.add_child(label)
	label.text = "+" + str(bonus_amt) + " (" + tag + ")"
	label.add_theme_font_size_override("font_size", 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.global_position = Vector2(
		roll_value_label.global_position.x,
		roll_value_label.global_position.y + 25
	)

	var tween = create_tween()
	tween.tween_property(
		label,
		"global_position:y",
		roll_value_label.global_position.y,
		bonus_tween_duration
	).set_delay(bonus_tween_delay)

	var complete_wrapper = func _complete_wrapper():
		roll_value_label.text = str(int(roll_value_label.text) + bonus_amt)
		label.queue_free()
		on_complete.call()
	tween.finished.connect(complete_wrapper)

func complete_roll():
	on_roll_complete.emit()

func scramble_numbers(num_scrambles: int, timer: Timer, final_value: int):
	if num_scrambles == 0:
		if timer != null:
			timer.queue_free()
		roll_value_label.text = str(final_value)
		
		var on_bonus_finished = func _on_bonus_finished():
			button.show()

		if static_bonus > 0:
			var on_complete = func _on_complete():
				if three_point_bonus > 0:
					add_roll_bonus(three_point_bonus, "3pt.", on_bonus_finished)
				else:
					on_bonus_finished.call()
			add_roll_bonus(static_bonus, "card", on_complete)
		elif three_point_bonus > 0:
			add_roll_bonus(three_point_bonus, "3pt.", on_bonus_finished)
		else:
			on_bonus_finished.call()
		return

	var num = generate_random_number()
	roll_value_label.text = str(num)

	var new_timer = Timer.new()
	new_timer.wait_time = scramble_wait_time
	new_timer.autostart = true
	new_timer.one_shot = true

	var callable = Callable(self, "scramble_numbers").bind(num_scrambles - 1, new_timer, final_value)
	new_timer.timeout.connect(callable)
	add_child(new_timer)

func generate_random_number():
	var rand_numbers = []
	for i in range(1, dice_type):
		rand_numbers.append(i)
	rand_numbers.shuffle()
	rand_numbers = rand_numbers.filter(func(x): return x != int(roll_value_label.text))
	return rand_numbers[0]
