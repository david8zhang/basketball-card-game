class_name DiceRoll
extends Panel

@onready var threshold_label: Label = $VBoxContainer/Threshold
@onready var roll_value_label: Label = $VBoxContainer/RollValue
@onready var result_label: Label = $VBoxContainer/Result

# Called when the node enters the scene tree for the first time.
func _ready():
	result_label.hide()
	roll_value(2)

func roll_value(value_to_roll: int):
	scramble_numbers(30, null, value_to_roll)

func scramble_numbers(num_scrambles: int, timer: Timer, final_value: int):
	if num_scrambles == 0:
		if timer != null:
			timer.queue_free()
		roll_value_label.text = str(final_value)
		return
	var num = randi_range(1, 20)
	roll_value_label.text = str(num)
	var new_timer = Timer.new()
	new_timer.wait_time = 0.01 + 0.0075 * (30 - num_scrambles)
	new_timer.autostart = true
	new_timer.one_shot = true
	var callable = Callable(self, "scramble_numbers").bind(num_scrambles - 1, new_timer, final_value)
	new_timer.timeout.connect(callable)
	add_child(new_timer)
