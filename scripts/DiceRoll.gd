class_name DiceRoll
extends Panel

@onready var roll_value_label: Label = $VBoxContainer/RollValue
@onready var button: Button = $VBoxContainer/Button

var curr_threshold: int
var curr_result_type: StrategyCardNode.NodeResultType
var dice_type: int

signal on_roll_complete

# Called when the node enters the scene tree for the first time.
func _ready():
	button.hide()
	button.pressed.connect(complete_roll)

func configure_dice_roll(condition_ref: RollDiceAction):
	dice_type = condition_ref.dice_type

func roll_value(value_to_roll: int):
	scramble_numbers(15, null, value_to_roll)

func complete_roll():
	on_roll_complete.emit()

func scramble_numbers(num_scrambles: int, timer: Timer, final_value: int):
	if num_scrambles == 0:
		if timer != null:
			timer.queue_free()
		roll_value_label.text = str(final_value)
		button.show()
		return
	var num = generate_random_number()
	roll_value_label.text = str(num)
	var new_timer = Timer.new()
	new_timer.wait_time = 0.075
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
