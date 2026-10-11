extends Visual

const LEFT_POINT_COLOR: Color = Color.RED
const RIGHT_POINT_COLOR: Color = Color.BLUE

const ROC_LINE_WIDTH: int = 5
const ROC_LINE_LENGTH: int = 35

const SLOPE_DISPLAY_OFFSET: Vector2 = Vector2(0.5, -0.5) * CalculatorSettings.SCALE
const SLOPE_DISPLAY_COLOR: Color = Color.DARK_TURQUOISE

const SLOPE_GRAPH_WIDTH: int = 5
const SLOPE_GRAPH_COLOR: Color = Color.DARK_MAGENTA
const SLOPE_GRAPH_ACCURACY: float = 0.01
const LINE_LENGTH_TOLERANCE: float = 5000

@onready var h_label = $HSlider/HLabel
@onready var x_spin: SpinBox = $XVariable/XSpinBox
@onready var x_slider: HSlider = $XSlider
@onready var derivative_display: RichTextLabel = $VBoxContainer/DerivativeDisplay/HBoxContainer/Answer

var x_variable: float = 0
var h_variable: float = 0
var hide_derivative_answer: bool = true
var hide_slope: bool = true
var draw_slope_curve: bool = false
var slope_graph_minimum: float = 0
var slope_graph_maximum: float = 0



func _on_h_slider_value_changed(value: float) -> void:
	value *= -1
	h_variable = 10**(value)
	var h_string: String = str(CalculatorFunctions.round_to_placement(value, STRING_ROUND))
	h_label.text = "h=10^" + h_string
	visual_layer.queue_redraw()

func _on_x_slider_value_changed(value: float) -> void:
	x_spin.value = CalculatorFunctions.round_to_placement(value, STRING_ROUND)

func _on_x_spin_box_value_changed(value: float) -> void:
	x_variable = value
	update_derivative_answer()
	
	if draw_slope_curve:
		if slope_graph_maximum < value:
			slope_graph_maximum = value
		if slope_graph_minimum > value:
			slope_graph_minimum = value
	visual_layer.queue_redraw()

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
		visual_layer.queue_redraw()
	else:
		hide_slope = true
		visual_layer.queue_redraw()

func visual_draw() -> void:
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
	var left_secant_position: Vector2 = point_center + secant_vector.normalized() * ROC_LINE_LENGTH
	var right_secant_position: Vector2 = point_center - secant_vector.normalized() * ROC_LINE_LENGTH
	left_secant_position = vector_to_graph(left_secant_position)
	right_secant_position = vector_to_graph(right_secant_position)

	visual_layer.draw_line(left_secant_position, right_secant_position, COORDINATE_COLOR, ROC_LINE_WIDTH)
	visual_layer.draw_circle(left_point_position, VISUAL_CIRCLE_SIZE, LEFT_POINT_COLOR)
	visual_layer.draw_circle(right_point_position, VISUAL_CIRCLE_SIZE, RIGHT_POINT_COLOR)
	if not hide_slope:
		var slope_string: String = "m = " + str(rate_of_change)
		visual_layer.draw_string(FONT, center_position + SLOPE_DISPLAY_OFFSET, slope_string, 0, -1, TEXT_SIZE, SLOPE_DISPLAY_COLOR)
	else:
		var slope_string: String = "m = ?"
		visual_layer.draw_string(FONT, center_position + SLOPE_DISPLAY_OFFSET, slope_string, 0, -1, TEXT_SIZE, SLOPE_DISPLAY_COLOR)
	
	if draw_slope_curve:
		draw_slope_graph()

func draw_slope_graph() -> void:
	var skip_line: bool = true
	var last_position: Vector2
	var current_function_name: String = CalculatorSettings.current_function_name
	for x: float in range(slope_graph_minimum/SLOPE_GRAPH_ACCURACY, slope_graph_maximum/SLOPE_GRAPH_ACCURACY):
		x *= SLOPE_GRAPH_ACCURACY
		var x1: float = x - h_variable
		var x2: float = x + h_variable
		var y1: Variant = CalculatorFunctions.fun(current_function_name, x1)
		var y2: Variant = CalculatorFunctions.fun(current_function_name, x2)
		var rate_of_change: float = (y2-y1)/(x2-x1)
		var y: float = rate_of_change
		if y == null or is_inf(y):
			skip_line = true
			continue
		var point_position: Vector2 = position_to_graph(x, y)
		if skip_line:
			last_position = point_position
			skip_line = false
		else:
			if (last_position - point_position).length() > LINE_LENGTH_TOLERANCE: 
				# fixes recurringly infinite graphs such as tan x
				# could also be done if line reaches the top of the graph
				print("line too long at: " + str(x))
				last_position = point_position
				continue
			visual_layer.draw_line(last_position, point_position, SLOPE_GRAPH_COLOR, SLOPE_GRAPH_WIDTH)
			last_position = point_position

func _on_draw_slope_curve_pressed() -> void:
	if not draw_slope_curve:
		draw_slope_curve = true
		slope_graph_maximum = x_variable
		slope_graph_minimum = x_variable
	else:
		draw_slope_curve = false
	visual_layer.queue_redraw()

func on_exit() -> void:
	visible = false
