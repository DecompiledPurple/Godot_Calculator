extends Visual

const LEFT_POINT_COLOR: Color = Color.RED
const RIGHT_POINT_COLOR: Color = Color.BLUE
const ROF_LINE_WIDTH: int = 5
const ROF_LINE_LENGTH = 35
const SLOPE_DISPLAY_OFFSET = Vector2(0.5, -0.5) * CalculatorSettings.SCALE
const SLOPE_DISPLAY_COLOR = Color.DARK_TURQUOISE

@onready var h_label = $HLabel
@onready var x_label = $XLabel
@onready var x_spin: SpinBox = $XVariable/XSpinBox
@onready var x_slider: HSlider = $XSlider
@onready var derivative_display: RichTextLabel = $VBoxContainer/DerivativeDisplay/HBoxContainer/Answer

var x_variable: float = 0
var h_variable: float = 0
var hide_derivative_answer: bool = true
var hide_slope: bool = true

func _ready() -> void:
	visual_draw = Callable(self, "derivative_visual_draw")

func _on_h_slider_value_changed(value: float) -> void:
	value *= -1
	h_variable = 10**(value)
	h_label.text = "h=10^" + str(value)
	graph_controller.queue_redraw()

func _on_x_slider_value_changed(value: float) -> void:
	x_spin.value = CalculatorFunctions.round_to_placement(value, 3)

func _on_x_spin_box_value_changed(value: float) -> void:
	x_variable = value
	update_derivative_answer()
	graph_controller.queue_redraw()

func update_derivative_answer():
	if hide_derivative_answer:
		derivative_display.text = "?"
	else:
		var derivative: Variant = CalculatorFunctions.deriv(CalculatorSettings.current_function_name, x_variable)
		derivative_display.text = str(derivative)

func _on_hide_derivative_answer_pressed() -> void:
	if hide_derivative_answer:
		hide_derivative_answer = false
		update_derivative_answer()
	else:
		hide_derivative_answer = true
		update_derivative_answer()

func _on_hide_slope_pressed() -> void:
	if hide_slope:
		hide_slope = false
		graph_controller.queue_redraw()
	else:
		hide_slope = true
		graph_controller.queue_redraw()

func derivative_visual_draw() -> void:
	var current_function_name: String = CalculatorSettings.current_function_name
	var center_y: Variant = CalculatorFunctions.fun(current_function_name, x_variable)
	var x1: float = x_variable - h_variable
	var x2: float = x_variable + h_variable
	var y1: Variant = CalculatorFunctions.fun(current_function_name, x1)
	var y2: Variant = CalculatorFunctions.fun(current_function_name, x2)
	var rate_of_change: float = (y2-y1)/(x2-x1)

	var left_point_position: Vector2 = position_to_graph(x1, y1)
	var right_point_position: Vector2 = position_to_graph(x2, y2)
	var center_position: Vector2 = position_to_graph(x_variable, center_y)
	var secant_vector: Vector2 = Vector2(x2 - x1, y2 - y1)
	var point_center: Vector2 = Vector2(x1, y1) + secant_vector/2
	var left_secant_position: Vector2 = point_center + secant_vector.normalized() * ROF_LINE_LENGTH
	var right_secant_position: Vector2 = point_center - secant_vector.normalized() * ROF_LINE_LENGTH
	left_secant_position = vector_to_graph(left_secant_position)
	right_secant_position = vector_to_graph(right_secant_position)

	graph_controller.draw_line(left_secant_position, right_secant_position, COORDINATE_COLOR, ROF_LINE_WIDTH)
	graph_controller.draw_circle(left_point_position, VISUAL_CIRCLE_SIZE, LEFT_POINT_COLOR)
	graph_controller.draw_circle(right_point_position, VISUAL_CIRCLE_SIZE, RIGHT_POINT_COLOR)
	if not hide_slope:
		var slope_string: String = "m = " + str(rate_of_change)
		graph_controller.draw_string(FONT, center_position + SLOPE_DISPLAY_OFFSET, slope_string, 0, -1, TEXT_SIZE, SLOPE_DISPLAY_COLOR)
	else:
		var slope_string: String = "m = ?"
		graph_controller.draw_string(FONT, center_position + SLOPE_DISPLAY_OFFSET, slope_string, 0, -1, TEXT_SIZE, SLOPE_DISPLAY_COLOR)
