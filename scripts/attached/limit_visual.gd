extends Visual

class_name LimitVisual

const DECIMAL_POINT_ROUND: int = 3
const LEFT_LIMIT_COLOR: Color = Color.RED
const RIGHT_LIMIT_COLOR: Color = Color.BLUE
const LIMIT_CIRCLE_SIZE: int = 5
const LIMIT_COORDINATE_OFFSET: Vector2 = Vector2(0.5,0.5) * CalculatorSettings.SCALE

signal h_variable_changed(new_h: float)
signal n_variable_changed(new_n: float)

@onready var h_slider: HSlider = $HSlide
@onready var h_label: Label = $HLabel
@onready var right_limit_answer: RichTextLabel = $RightLimitDisplay/HBoxContainer/Answer
@onready var left_limit_answer: RichTextLabel = $LeftLimitDisplay/HBoxContainer/Answer
@onready var main_limit_answer: RichTextLabel = $MainLimitDisplay/HBoxContainer/Answer
@onready var hide_limit_answer_button: CheckBox  = $Settings/HideLimitAnswer

var graph_controller:Node2D # set by graph
var hide_limit_answer: bool = true
var limit_answer: Variant = 0

func _ready() -> void:
	visual_draw = Callable(self, "limit_visual_draw")
	on_visual_entered = Callable(self, "on_limit_visual_entered")

func _on_n_spin_box_value_changed(value: float) -> void:
	n_variable = value
	n_variable_changed.emit(value)

func _on_h_slider_value_changed(value: float) -> void:
	h_variable = 9**(-value)
	h_variable_changed.emit(h_variable)
	h_label.text = "10^(" + str(-value) + ")"

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

func limit_visual_draw() -> void:
	var current_function_name = CalculatorSettings.current_function_name
	var x1 = h_variable + n_variable
	var y1 = CalculatorFunctions.fun(current_function_name, x1)
	var x2 = n_variable - h_variable
	var y2 = CalculatorFunctions.fun(current_function_name, x2)
	var center_y: Variant = CalculatorFunctions.lim(current_function_name,
	 n_variable)
	var limit_exists: bool = not center_y is String
	var left_approach_position: Vector2 = position_to_graph(x2, y2)
	var right_approach_position: Vector2 = position_to_graph(x1, y1)
	var left_coordinate: String = "(" + str(x2) + ", " + str(y2) + ")"
	var right_coordinate: String = "(" + str(x1) + ", " + str(y1) + ")"
	graph_controller.draw_circle(left_approach_position, LIMIT_CIRCLE_SIZE, LEFT_LIMIT_COLOR)
	graph_controller.draw_circle(right_approach_position, LIMIT_CIRCLE_SIZE, RIGHT_LIMIT_COLOR)
	graph_controller.draw_string(FONT, left_approach_position - LIMIT_COORDINATE_OFFSET, left_coordinate, 0, -1, 16, COORDINATE_COLOR)
	graph_controller.draw_string(FONT, right_approach_position + LIMIT_COORDINATE_OFFSET, right_coordinate, 0, -1, 16, COORDINATE_COLOR)
	
	update_left_limit_label(y2)
	update_right_limit_label(y1)
	update_main_limit_label(center_y)
	
	if limit_exists and not hide_limit_answer:
		var center_position: Vector2 = position_to_graph(n_variable
		 ,center_y)
		graph_controller.draw_circle(center_position, 2, Color.PURPLE)
	
func on_limit_visual_entered() -> void:
	visible = true
	graph_controller.queue_redraw()
