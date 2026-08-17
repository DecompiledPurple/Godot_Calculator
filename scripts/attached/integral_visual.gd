extends Visual

const LEFT_SUM_NUMBER: int = 0
const MIDDLE_SUM_NUMBER: int = 1
const RIGHT_SUM_NUMBER: int = 2

const INTEGRAL_COLOR1: Color = Color.RED
const INTEGRAL_COLOR2: Color = Color.BLUE
const INTEGRAL_WIDTH: int = 3
const INTEGRAL_VERTEX_SIZE: int = 5

const DELTA_X_HEIGHT: int = -1
const DELTA_X_COLOR: Color = Color.PURPLE
const DELTA_X_WIDTH: int = 5
const DELTA_X_TEXT_POSITION: Vector2 = Vector2(1, -2)
const DELTA_X_TEXT_SIZE: int = 32

const AREA_TEXT_SIZE: int = 22
const AREA_ROUND_PLACEMENT: int = 3

var n_variable: int = 1
var a_variable: float = 0
var b_variable: float = 1
var sum_direction: int = 0
var show_rectangle_areas: bool = true

var sum_direction_functions: Array[Callable] = [
	left_sum_draw,
	middle_sum_draw,
	right_sum_draw
]

@onready var n_spin_box: SpinBox = $VBoxContainer2/NVariable/NSpinBox

func _ready() -> void:
	visual_draw = Callable(self, "integral_visual_draw")

func _on_n_spin_box_value_changed(value: float) -> void:
	n_variable = value
	graph_controller.queue_redraw()

func _on_h_slider_value_changed(value: float) -> void:
	n_spin_box.value = value

func _on_b_spin_box_value_changed(value: float) -> void:
	b_variable = value
	graph_controller.queue_redraw()

func _on_a_spin_box_value_changed(value: float) -> void:
	a_variable = value
	graph_controller.queue_redraw()

func _on_direction_slider_value_changed(value: float) -> void:
	sum_direction = value
	graph_controller.queue_redraw()

func integral_visual_draw() -> void:
	var delta_x: float = (b_variable - a_variable)/n_variable
	for i in range(0, n_variable):
		sum_direction_functions[sum_direction].call(i, delta_x)

	var middle_graph_position: Vector2 = position_to_graph(0,0)
	var position1: Vector2 = position_to_graph(0, DELTA_X_HEIGHT)
	var position2: Vector2 = position_to_graph(delta_x, DELTA_X_HEIGHT)
	var position3: Vector2 = position_to_graph(delta_x, 0)
	var text_position: Vector2 = vector_to_graph(DELTA_X_TEXT_POSITION)
	var delta_text: String = "dx = " + str(delta_x)
	graph_controller.draw_line(middle_graph_position, position1, DELTA_X_COLOR, DELTA_X_WIDTH)
	graph_controller.draw_line(position1, position2, DELTA_X_COLOR, DELTA_X_WIDTH)
	graph_controller.draw_line(position2, position3, DELTA_X_COLOR)
	graph_controller.draw_string(FONT, text_position, delta_text, 0, -1, DELTA_X_TEXT_SIZE, DELTA_X_COLOR)

func draw_rectangle_area_text(x: float, y: float, delta_x: float):
	if not show_rectangle_areas:
		return
	var area: float = delta_x * y
	area = CalculatorFunctions.round_to_placement(area, AREA_ROUND_PLACEMENT)
	var text_position: Vector2 = position_to_graph(x, y/2)
	var text: String = "A = " + str(area)
	print("writing area of " + text + " at " + str(text_position))
	graph_controller.draw_circle(text_position, 4, Color.AQUA)
	graph_controller.draw_string(FONT, text_position, str(area), 0, -1, AREA_TEXT_SIZE, Color.PURPLE)

func left_sum_draw(iteration, delta_x):
	var input: float = a_variable + delta_x * iteration
	var y: float = CalculatorFunctions.fun(CalculatorSettings.current_function_name, input)
	# print("drawing at: " + str(input) + " : " + str(y) + " dx = " + str(delta_x))
	var area_rect: Rect2 = Rect2(input, y, delta_x, y)
	var vertex_position: Vector2 = position_to_graph(input, y)
	var current_color: Color = INTEGRAL_COLOR1
	if iteration % 2 == 1:
		current_color = INTEGRAL_COLOR2
	area_rect = rect_to_graph(area_rect)
	graph_controller.draw_rect(area_rect, current_color, false, INTEGRAL_WIDTH)
	graph_controller.draw_circle(vertex_position, INTEGRAL_VERTEX_SIZE, current_color)
	current_color.a = 0.25
	graph_controller.draw_rect(area_rect, current_color)
	draw_rectangle_area_text(input, y, delta_x)

func right_sum_draw(iteration, delta_x):
	var input: float = a_variable + delta_x * (iteration + 1)
	var x: float = input - delta_x
	var y: float = CalculatorFunctions.fun(CalculatorSettings.current_function_name, input)
	# print("drawing at: " + str(input) + " : " + str(y) + " dx = " + str(delta_x))
	var area_rect: Rect2 = Rect2(x, y, delta_x, y)
	var vertex_position: Vector2 = position_to_graph(input, y)
	var current_color: Color = INTEGRAL_COLOR1
	if iteration % 2 == 1:
		current_color = INTEGRAL_COLOR2
	area_rect = rect_to_graph(area_rect)
	graph_controller.draw_rect(area_rect, current_color, false, INTEGRAL_WIDTH)
	graph_controller.draw_circle(vertex_position, INTEGRAL_VERTEX_SIZE, current_color)
	current_color.a = 0.25
	graph_controller.draw_rect(area_rect, current_color)
	draw_rectangle_area_text(x, y, delta_x)
	

func middle_sum_draw(iteration, delta_x):
	var input: float = a_variable + delta_x * iteration
	var input2: float = input + delta_x
	var middle_x: float = (input+input2)/2
	var y: float = CalculatorFunctions.fun(CalculatorSettings.current_function_name, input)
	var y2: float = CalculatorFunctions.fun(CalculatorSettings.current_function_name, input2)
	var middle_y: float = (y+y2)/2

	# print("drawing at: " + str(input) + " : " + str(y) + " dx = " + str(delta_x))
	var area_rect: Rect2 = Rect2(input, middle_y, delta_x, middle_y)
	var vertex_position: Vector2 = position_to_graph(middle_x, middle_y)
	var current_color: Color = INTEGRAL_COLOR1
	if iteration % 2 == 1:
		current_color = INTEGRAL_COLOR2
	area_rect = rect_to_graph(area_rect)
	graph_controller.draw_rect(area_rect, current_color, false, INTEGRAL_WIDTH)
	graph_controller.draw_circle(vertex_position, INTEGRAL_VERTEX_SIZE, current_color)
	current_color.a = 0.25
	graph_controller.draw_rect(area_rect, current_color)
	draw_rectangle_area_text(input, middle_y, delta_x)
