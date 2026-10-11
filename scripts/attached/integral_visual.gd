extends Visual

const LEFT_SUM_NUMBER: int = 0
const MIDDLE_SUM_NUMBER: int = 1
const RIGHT_SUM_NUMBER: int = 2

const INTEGRAL_COLOR1: Color = Color.BLUE
const INTEGRAL_COLOR2: Color = Color.AQUA
const INTEGRAL_COLOR3: Color = Color.RED
const INTEGRAL_COLOR4: Color = Color.DEEP_PINK
const INTEGRAL_WIDTH: int = 3
const INTEGRAL_VERTEX_SIZE: int = 5
const INTEGRAL_TRANSPARENCY: float = 0.25

const DELTA_X_HEIGHT: int = -1
const DELTA_X_COLOR: Color = Color.PURPLE
const DELTA_X_WIDTH: int = 5
const DELTA_X_TEXT_POSITION: Vector2 = Vector2(1, -2)
const DELTA_X_TEXT_SIZE: int = 32
const VERTEX_DELTA_X_MINIMUM: float = 0.2

const AREA_TEXT_SIZE: int = 22
const AREA_ROUND_PLACEMENT: int = 3
const AREA_TEXT_COLOR: Color = Color.REBECCA_PURPLE
const AREA_TEXT_POSITION: Vector2 = Vector2(1, 2)

var n_variable: int = 1
var a_variable: float = 0
var b_variable: float = 1
var sum_direction: int = 0 # change to float soon
var hide_rectangle_areas: bool = true
var hide_integral_answer: bool = true
var second_function_name: String

var sum_direction_functions: Array[Callable] = [ # this is obsolete, rewrite later
	left_sum_draw,
	middle_sum_draw,
	right_sum_draw
]

@onready var n_spin_box: SpinBox = $VBoxContainer2/NVariable/NSpinBox
@onready var integral_answer: RichTextLabel = $VBoxContainer/IntegralDisplay/HBoxContainer/Answer

func _ready() -> void:
	visual_draw = Callable(self, "integral_visual_draw")

func _on_n_spin_box_value_changed(value: float) -> void:
	n_variable = value
	visual_layer.queue_redraw()

func _on_h_slider_value_changed(value: float) -> void:
	n_spin_box.value = value

func _on_b_spin_box_value_changed(value: float) -> void:
	b_variable = value
	visual_layer.queue_redraw()

func _on_a_spin_box_value_changed(value: float) -> void:
	a_variable = value
	visual_layer.queue_redraw()

func _on_direction_slider_value_changed(value: float) -> void:
	sum_direction = value
	visual_layer.queue_redraw()

func integral_visual_draw() -> void:
	var delta_x: float = (b_variable - a_variable)/n_variable
	for i in range(0, n_variable):
		sum_direction_functions[sum_direction].call(i, delta_x)

	var middle_graph_position: Vector2 = position_to_graph(0, 0)
	var position1: Vector2 = position_to_graph(0, DELTA_X_HEIGHT)
	var position2: Vector2 = position_to_graph(delta_x, DELTA_X_HEIGHT)
	var position3: Vector2 = position_to_graph(delta_x, 0)
	var text_position: Vector2 = vector_to_graph(DELTA_X_TEXT_POSITION)
	var delta_text: String = "dx = " + str(delta_x)
	visual_layer.draw_line(middle_graph_position, position1, DELTA_X_COLOR, DELTA_X_WIDTH)
	visual_layer.draw_line(position1, position2, DELTA_X_COLOR, DELTA_X_WIDTH)
	visual_layer.draw_line(position2, position3, DELTA_X_COLOR)
	visual_layer.draw_string(FONT, text_position, delta_text, 0, -1, DELTA_X_TEXT_SIZE, DELTA_X_COLOR)
	if not hide_integral_answer:
		var integral_answer_value: Variant = CalculatorFunctions.integrate(CalculatorSettings.current_function_name, a_variable, b_variable)
		integral_answer.text = str(integral_answer_value)
	else:
		integral_answer.text = "?"

func draw_rectangle_area_text(x: float, y: float, delta_x: float) -> float:
	if hide_rectangle_areas:
		return 0
	var area: float = delta_x * y
	var text_position: Vector2 = Vector2(x + AREA_TEXT_POSITION.x, y)
	if y > 0:
		text_position += Vector2(0, AREA_TEXT_POSITION.y)
	else:
		text_position -= Vector2(0, AREA_TEXT_POSITION.y)
	area = CalculatorFunctions.round_to_placement(area, AREA_ROUND_PLACEMENT)
	text_position = vector_to_graph(text_position)
	var text: String = "A = " + str(area)
	visual_layer.draw_string(FONT, text_position, text, 0, -1, AREA_TEXT_SIZE, AREA_TEXT_COLOR)
	return area


func reimann_sum_draw(iteration: int, delta_x: float, direction: float):
	var x: float = a_variable + delta_x * (iteration + direction)
	var x2: float = a_variable + delta_x * iteration
	var y: float = CalculatorFunctions.fun(CalculatorSettings.current_function_name, x)
	var area_rect: Rect2 = Rect2(x2, y, delta_x, y)
	var vertex_position: Vector2 = position_to_graph(x, y)
	var current_color: Color = INTEGRAL_COLOR1
	if y > 0:
		if iteration % 2 == 1:
			current_color = INTEGRAL_COLOR2
	else: 
		current_color = INTEGRAL_COLOR3
		if iteration % 2 == 1:
			current_color = INTEGRAL_COLOR4
	area_rect = rect_to_graph(area_rect)
	visual_layer.draw_rect(area_rect, current_color, false, INTEGRAL_WIDTH)
	current_color.a = INTEGRAL_TRANSPARENCY 
	visual_layer.draw_rect(area_rect, current_color)
	if delta_x >= VERTEX_DELTA_X_MINIMUM:
		current_color.a = 1
		visual_layer.draw_circle(vertex_position, INTEGRAL_VERTEX_SIZE, current_color)
		draw_rectangle_area_text(x2, y, delta_x)

func left_sum_draw(iteration, delta_x):
	reimann_sum_draw(iteration, delta_x, 0)
func right_sum_draw(iteration, delta_x):
	reimann_sum_draw(iteration, delta_x, 1)
func middle_sum_draw(iteration, delta_x):
	reimann_sum_draw(iteration, delta_x, 0.5)

func _on_hide_integral_answer_pressed() -> void:
	if hide_integral_answer: 
		hide_integral_answer = false
	else:
		hide_integral_answer = true
	visual_layer.queue_redraw()

func _on_hide_rectangle_areas_pressed() -> void:
	if hide_rectangle_areas:
		hide_rectangle_areas = false
	else:
		hide_rectangle_areas = true
	visual_layer.queue_redraw()

func _on_second_function_name_text_changed(new_text: String) -> void:
	second_function_name = new_text
	visual_layer.queue_redraw()
