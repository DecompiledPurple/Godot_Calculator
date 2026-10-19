extends Visual

class_name Integral_Visual

signal enter_geometric_view(sum_positions: Array[Vector2])
signal update_sum_positions(sum_positions: Array[Vector2])
signal exit_geometric_view()

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
const INTEGRAL_TRANSPARENCY2: float = 0.1
const INTEGRAL_INFO_Y_OFFSET: float = -0.75
const INTEGRAL_INFO_X_OFFSET: float = -1.5
const INTEGRAL_INFO_COLOR: Color = Color.ORANGE_RED

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
var in_geometric_view: bool = false
var geometric_index: int = 0 
var show_hidden_sums: bool = false

var sum_direction_functions: Array[Callable] = [ # this is obsolete, rewrite later
	left_sum_draw,
	middle_sum_draw,
	right_sum_draw
]

var reimann_sum_positions: Array[Vector2]

@onready var n_spin_box: SpinBox = $VBoxContainer2/NVariable/NSpinBox
@onready var integral_answer: RichTextLabel = $VBoxContainer/IntegralDisplay/HBoxContainer/Answer
@onready var second_function_text_box: LineEdit = $SecondFunctionName
@onready var geometric_view_button: Button = $GeometricView

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

func visual_draw() -> void:
	var has_second_function: bool = CalculatorFunctions.has_function(second_function_name) or false
	var delta_x: float = (b_variable - a_variable)/n_variable
	reimann_sum_positions.clear()
	for i in range(0, n_variable):
		sum_direction_functions[sum_direction].call(i, delta_x, has_second_function)
	if in_geometric_view:
		update_sum_positions.emit(reimann_sum_positions)
	
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
	if not hide_integral_answer and not has_second_function:
		# integration with a second function needs to be added
		var integral_answer_value: Variant = CalculatorFunctions.integrate(CalculatorSettings.current_function_name, a_variable, b_variable) 
		integral_answer.text = str(integral_answer_value)
	else:
		integral_answer.text = "?"

func draw_rectangle_area_text(x: float, y: float, delta_x: float) -> float:
	if hide_rectangle_areas:
		return 0
	var area: float = delta_x * y
	var text_position: Vector2 = Vector2(x + AREA_TEXT_POSITION.x, y/2)
	if y > 0:
		text_position += Vector2(0, AREA_TEXT_POSITION.y/2)
	else:
		text_position -= Vector2(0, AREA_TEXT_POSITION.y/.2)
	area = CalculatorFunctions.round_to_placement(area, AREA_ROUND_PLACEMENT)
	text_position = vector_to_graph(text_position)
	var text: String = "A = " + str(area)
	visual_layer.draw_string(FONT, text_position, text, 0, -1, AREA_TEXT_SIZE, AREA_TEXT_COLOR)
	return area

func reimann_sum_draw(iteration: int, delta_x: float, direction: float, has_second_function: bool):
	var x: float = a_variable + delta_x * (iteration + direction)
	var corner_x: float = a_variable + delta_x * iteration
	var y: float = CalculatorFunctions.fun(CalculatorSettings.current_function_name, x)
	var y2: float

	var area_rect: Rect2
	var area_rect_top: Rect2
	var area_rect_bottom: Rect2
	var vertex_position: Vector2
	var current_color: Color
	var negative_color: Color
	var positive_color: Color

	var top_function_name: String
	var bottom_function_name: String
	var top_y: float
	var bottom_y: float

	var is_writing_area: bool = false
	var selected_written_height: float
	var height_text: String
	var width_text: String
	var written_function_name: String

	if has_second_function:
		y2 = CalculatorFunctions.fun(second_function_name, x)
		if y2 > y:
			top_y = y2
			bottom_y = y
			top_function_name = second_function_name
			bottom_function_name = CalculatorSettings.current_function_name
		else:
			top_y = y
			bottom_y = y2
			top_function_name = CalculatorSettings.current_function_name
			bottom_function_name = second_function_name
		y2 = CalculatorFunctions.fun(second_function_name, x)
		area_rect = Rect2(corner_x, top_y, delta_x, top_y - bottom_y)
		vertex_position = Vector2(top_y, x)
		reimann_sum_positions.append(Vector2(corner_x + delta_x/2, top_y/2))
		reimann_sum_positions.append(Vector2(corner_x + delta_x/2, bottom_y/2))
	else:
		area_rect = Rect2(corner_x, y, delta_x, y)
		reimann_sum_positions.append(Vector2(corner_x + delta_x/2, y/2))

	if iteration % 2 == 1:
		positive_color = INTEGRAL_COLOR2
		negative_color = INTEGRAL_COLOR4
	else:
		positive_color = INTEGRAL_COLOR1
		negative_color = INTEGRAL_COLOR3
	if y > 0:
		current_color = positive_color
	else: 
		current_color = negative_color

	area_rect = rect_to_graph(area_rect)
	if in_geometric_view and has_second_function:
		area_rect_top = Rect2(corner_x, top_y, delta_x, top_y)
		area_rect_bottom = Rect2(corner_x, bottom_y, delta_x, bottom_y)
		area_rect_top = rect_to_graph(area_rect_top)
		area_rect_bottom = rect_to_graph(area_rect_bottom)
		# on top reimann sum selected
		if geometric_index == iteration * 2:
			if top_y > 0:
				current_color = positive_color
			else:
				current_color = negative_color
			visual_layer.draw_rect(area_rect_top, current_color, false, INTEGRAL_WIDTH)
			current_color.a = INTEGRAL_TRANSPARENCY
			visual_layer.draw_rect(area_rect_top, current_color)

			selected_written_height= top_y
			written_function_name = top_function_name
			is_writing_area = true
			draw_rectangle_area_text(x, top_y, delta_x)
		# on bottom reimann sum selected
		elif geometric_index == iteration * 2 + 1:
			if bottom_y > 0:
				current_color = negative_color
			else:
				current_color = positive_color
			visual_layer.draw_rect(area_rect_bottom, current_color, false, INTEGRAL_WIDTH)
			current_color.a = INTEGRAL_TRANSPARENCY
			visual_layer.draw_rect(area_rect_bottom, current_color)
			current_color = positive_color
			current_color.a = INTEGRAL_TRANSPARENCY2
			visual_layer.draw_rect(area_rect, current_color)

			written_function_name = "-" + bottom_function_name
			selected_written_height= -bottom_y
			is_writing_area = true
		# neither selected
		else:
			var first_drawn_rect: Rect2
			var first_drawn_color: Color
			var last_drawn_rect: Rect2
			var last_drawn_color: Color
			var transparency_used: float = INTEGRAL_TRANSPARENCY2
			if show_hidden_sums:
				transparency_used = 1
			# order matters when rendering to make sure the red section stays on top, render that section last.
			if top_y > 0:
				first_drawn_rect = area_rect_top
				first_drawn_color = positive_color
				first_drawn_color.a = transparency_used
				last_drawn_rect = area_rect_bottom
				if bottom_y > 0:
					last_drawn_color = negative_color
				else:
					last_drawn_color = positive_color
				last_drawn_color.a = transparency_used
			else:
				last_drawn_rect = area_rect_top
				last_drawn_color = negative_color
				last_drawn_color.a = transparency_used
				first_drawn_rect = area_rect_bottom
				if bottom_y > 0:
					first_drawn_color = negative_color
				else:
					first_drawn_color = positive_color
				first_drawn_color.a = transparency_used
			visual_layer.draw_rect(first_drawn_rect, first_drawn_color)
			visual_layer.draw_rect(last_drawn_rect, last_drawn_color)

	elif in_geometric_view and not geometric_index == iteration:
		if show_hidden_sums:
			current_color.a = 1
		else:
			current_color.a = INTEGRAL_TRANSPARENCY2
		visual_layer.draw_rect(area_rect, current_color)
	else:
		if has_second_function:
			current_color = positive_color
		visual_layer.draw_rect(area_rect, current_color, false, INTEGRAL_WIDTH)
		current_color.a = INTEGRAL_TRANSPARENCY
		visual_layer.draw_rect(area_rect, current_color)
		selected_written_height= y
		written_function_name = CalculatorSettings.current_function_name
		if in_geometric_view:
			is_writing_area = true
		draw_rectangle_area_text(x, y, delta_x)

	if is_writing_area:
		var height_text_position: Vector2
		var width_text_position: Vector2
		if hide_rectangle_areas:
			height_text = "h = " + str(written_function_name) + "(x)"
			width_text = "w = dx"
		else:
			height_text = "h = " + str(selected_written_height)
			width_text = "w = " + str(delta_x)
		height_text_position = Vector2(corner_x + INTEGRAL_INFO_X_OFFSET, selected_written_height/2)
		height_text_position = vector_to_graph(height_text_position)
		width_text_position = Vector2(corner_x, INTEGRAL_INFO_Y_OFFSET)
		width_text_position = vector_to_graph(width_text_position)
		visual_layer.draw_string(FONT, height_text_position, height_text, 0, -1, AREA_TEXT_SIZE, INTEGRAL_INFO_COLOR)
		visual_layer.draw_string(FONT, width_text_position, width_text, 0, -1, AREA_TEXT_SIZE, INTEGRAL_INFO_COLOR)

	if delta_x >= VERTEX_DELTA_X_MINIMUM:
		current_color.a = 1
		visual_layer.draw_circle(vertex_position, INTEGRAL_VERTEX_SIZE, current_color)

func left_sum_draw(iteration, delta_x, has_second_function):
	reimann_sum_draw(iteration, delta_x, 0, has_second_function)
func right_sum_draw(iteration, delta_x, has_second_function):
	reimann_sum_draw(iteration, delta_x, 1, has_second_function)
func middle_sum_draw(iteration, delta_x, has_second_function):
	reimann_sum_draw(iteration, delta_x, 0.5, has_second_function)

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
	graph_controller.second_function_name = new_text
	visual_layer.queue_redraw()
	graph_controller.queue_redraw()

func on_exit() -> void:
	second_function_name = ""
	reimann_sum_positions.clear()
	in_geometric_view = false
	exit_geometric_view.emit()
	geometric_view_button.text = "Enter Geometric View"
	visible = false

func _on_second_function_name_editing_toggled(toggled_on: bool) -> void:
	if toggled_on:
		second_function_text_box.clear()

func _on_geometric_view_pressed() -> void:
	if in_geometric_view:
		in_geometric_view = false
		exit_geometric_view.emit()
		geometric_view_button.text = "Enter Geometric View"
		visual_layer.queue_redraw()
	else:
		in_geometric_view = true
		enter_geometric_view.emit(reimann_sum_positions)
		geometric_view_button.text = "Exit Geometric View"
		visual_layer.queue_redraw()

func _on_show_hidden_sums_pressed() -> void:
	if show_hidden_sums:
		show_hidden_sums = false
	else:
		show_hidden_sums = true
	visual_layer.queue_redraw()
