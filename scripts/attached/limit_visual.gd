extends Visual

const DECIMAL_POINT_ROUND: int = 3
const LEFT_LIMIT_COLOR: Color = Color.RED
const RIGHT_LIMIT_COLOR: Color = Color.BLUE
const LIMIT_COORDINATE_OFFSET: Vector2 = Vector2(0.5, -0.5) * CalculatorSettings.SCALE
const LIMIT_CIRCLE_COLOR: Color = Color.PURPLE
const IS_LIMIT_CIRCLE_FILLED: bool = false

@onready var h_slider: HSlider = $HSlider
@onready var h_label: Label = $HSlider/HLabel
@onready var right_limit_answer: RichTextLabel = $RightLimitDisplay/HBoxContainer/Answer
@onready var left_limit_answer: RichTextLabel = $LeftLimitDisplay/HBoxContainer/Answer
@onready var main_limit_answer: RichTextLabel = $MainLimitDisplay/HBoxContainer/Answer
@onready var hide_limit_answer_button: CheckBox  = $Settings/HideLimitAnswer

var h_variable: float = 0
var n_variable: float = 0
var hide_limit_answer: bool = true
var limit_answer: Variant = 0

func _ready() -> void:
	visual_draw = Callable(self, "limit_visual_draw")

func _on_n_spin_box_value_changed(value: float) -> void:
	n_variable = value
	visual_layer.queue_redraw()

func _on_h_slider_value_changed(value: float) -> void:
	h_variable = 10**(-value)
	var value_string: String = str(CalculatorFunctions.round_to_placement(value, STRING_ROUND))
	h_label.text = "h = 10^(" + value_string + ")"
	visual_layer.queue_redraw()

func update_left_limit_label(y_value: float) -> void:
	y_value = CalculatorFunctions.round_to_placement(y_value, DECIMAL_POINT_ROUND)
	left_limit_answer.text = str(y_value)
	
func update_right_limit_label(y_value: float) -> void:
	y_value = CalculatorFunctions.round_to_placement(y_value, DECIMAL_POINT_ROUND)
	right_limit_answer.text = str(y_value)

func update_main_limit_label(y_value: Variant) -> void:
	if not hide_limit_answer:
		main_limit_answer.text = str(y_value)
	limit_answer = y_value

func _on_hide_limit_answer_pressed() -> void:
	hide_limit_answer = hide_limit_answer_button.button_pressed
	if hide_limit_answer:
		main_limit_answer.text = "?"
	else: 
		main_limit_answer.text = str(limit_answer)
	visual_layer.queue_redraw()

func limit_visual_draw() -> void:
	var current_function_name = CalculatorSettings.current_function_name
	var x1 = h_variable + n_variable
	var y1 = CalculatorFunctions.fun(current_function_name, x1)
	var x2 = n_variable - h_variable
	var y2 = CalculatorFunctions.fun(current_function_name, x2)
	var center_y: Variant = CalculatorFunctions.lim(current_function_name, n_variable)
	var limit_exists: bool = not center_y is String
	var left_approach_position: Vector2 = position_to_graph(x2, y2)
	var right_approach_position: Vector2 = position_to_graph(x1, y1)
	var x2_text: String = str(CalculatorFunctions.round_to_placement(x2, STRING_ROUND))
	var y2_text: String = str(CalculatorFunctions.round_to_placement(y2, STRING_ROUND))
	var x1_text: String = str(CalculatorFunctions.round_to_placement(x1, STRING_ROUND))
	var y1_text: String = str(CalculatorFunctions.round_to_placement(y1, STRING_ROUND))

	var left_coordinate: String = "(" + x2_text + ", " + y2_text + ")"
	var right_coordinate: String = "(" + x1_text + ", " + y1_text + ")"
	visual_layer.draw_circle(left_approach_position, VISUAL_CIRCLE_SIZE, LEFT_LIMIT_COLOR)
	visual_layer.draw_circle(right_approach_position, VISUAL_CIRCLE_SIZE, RIGHT_LIMIT_COLOR)
	visual_layer.draw_string(FONT, left_approach_position - LIMIT_COORDINATE_OFFSET, left_coordinate, 0, -1, TEXT_SIZE, COORDINATE_COLOR)
	visual_layer.draw_string(FONT, right_approach_position + LIMIT_COORDINATE_OFFSET, right_coordinate, 0, -1, TEXT_SIZE, COORDINATE_COLOR)
	
	update_left_limit_label(y2)
	update_right_limit_label(y1)
	update_main_limit_label(center_y)
	
	if limit_exists and not hide_limit_answer:
		var center_position: Vector2 = position_to_graph(n_variable, center_y)
		visual_layer.draw_circle(center_position, VISUAL_CIRCLE_SIZE, LIMIT_CIRCLE_COLOR, IS_LIMIT_CIRCLE_FILLED)
