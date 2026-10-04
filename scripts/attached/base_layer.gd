extends Node2D


const Y_SIZE: int = CalculatorSettings.Y_SIZE
const X_SIZE: int = CalculatorSettings.X_SIZE
const SCALE: int = CalculatorSettings.SCALE
const GRAPH_WIDTH: int = 5
const AXIS_WIDTH: int = 3
const LINE_WIDTH: int = 2
const MINIMUM_RANGE = -20
const MAXIMUM_RANGE = 20
const HORIZONTAL_TEXT_OFFSET: Vector2 = Vector2(0.15, -0.3) * CalculatorSettings.SCALE
const VERTICAL_TEXT_OFFSET: Vector2 = Vector2(0.3, -0.15) * CalculatorSettings.SCALE
const NUMBER_TEXT_SIZE: int = 20

var background_color: Color = Color.BLACK
var graph_color: Color = Color.BLACK


func _ready() -> void:
	queue_redraw()

func _process(_delta: float) -> void:
	pass

func _draw() -> void:
	draw_base_graph()

func position_to_graph(x: float, y: float) -> Vector2:
	var SCALE = CalculatorSettings.SCALE
	var Y_SIZE = CalculatorSettings.Y_SIZE
	var X_SIZE = CalculatorSettings.X_SIZE
	var scaled_position: Vector2 = Vector2(x, y) * SCALE
	return Vector2(scaled_position.x + X_SIZE/2, -scaled_position.y + Y_SIZE/2)

func vector_to_graph(vector: Vector2) -> Vector2:
	var SCALE = CalculatorSettings.SCALE
	var Y_SIZE = CalculatorSettings.Y_SIZE
	var X_SIZE = CalculatorSettings.X_SIZE
	var scaled_vector: Vector2 = vector * SCALE
	return Vector2(scaled_vector.x + X_SIZE/2, -scaled_vector.y + Y_SIZE/2)


func draw_base_graph() -> void:
	#draw_circle(Vector2.ZERO, 200, background_color, true)
	# draw_circle(Vector2(500,500), 50, Color.REBECCA_PURPLE)
	draw_line(Vector2(0, Y_SIZE/2), Vector2(X_SIZE, Y_SIZE/2), background_color, GRAPH_WIDTH)
	draw_line(Vector2(X_SIZE/2, 0), Vector2(X_SIZE/2, Y_SIZE), background_color, GRAPH_WIDTH)
	
	for index in range(0, X_SIZE/SCALE):
		if index == MAXIMUM_RANGE:
			continue
		var current_step: int = index * SCALE
		draw_line(Vector2(current_step, 0), Vector2(current_step, Y_SIZE), background_color, LINE_WIDTH)
		draw_string(CalculatorSettings.FONT, Vector2(current_step, Y_SIZE/2 ) + HORIZONTAL_TEXT_OFFSET, str(index + MINIMUM_RANGE), 0, -1, NUMBER_TEXT_SIZE, Color.BLACK)
		draw_string(CalculatorSettings.FONT, Vector2(X_SIZE/2, current_step) + VERTICAL_TEXT_OFFSET, str(MAXIMUM_RANGE - index), 0, -1, NUMBER_TEXT_SIZE, Color.BLACK)
		draw_line(Vector2(current_step, Y_SIZE/2 - Y_SIZE/100), Vector2(current_step, Y_SIZE/2 + Y_SIZE/100), background_color, AXIS_WIDTH)
		draw_line(Vector2(0, current_step), Vector2(X_SIZE, current_step), background_color, LINE_WIDTH)
		draw_line(Vector2(X_SIZE/2 - X_SIZE/100, current_step), Vector2(X_SIZE/2 + X_SIZE/100, current_step), background_color, AXIS_WIDTH)
