extends Node2D

const PIXEL_STEP: int = 25
const FUNCTION_ACCURACCY: float = 0.1
const MINIMUM_RANGE: int = -50
const MAXIMUM_RANGE: int = 50
const GRAPH_WIDTH: int = 5
const AXIS_WIDTH: int = 3
const LINE_WIDTH: int = 2
const Y_SIZE: int = 1000
const X_SIZE: int = 1000

var background_color: Color = Color.BLACK
var graph_color: Color = Color.BLACK

@export var target_calculator: Calculator 
var current_function_name: String 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_calculator.graph_function.connect(on_graph)
	queue_redraw()

func _draw() -> void:
	draw_base_graph()
	draw_current_graph()

func on_graph(function_name: String) -> void:
	current_function_name = function_name
	queue_redraw()

func draw_base_graph() -> void:
	#draw_circle(Vector2.ZERO, 200, background_color, true)
	# draw_circle(Vector2(500,500), 50, Color.REBECCA_PURPLE)
	draw_line(Vector2(0, 500), Vector2(X_SIZE, 500), background_color, GRAPH_WIDTH)
	draw_line(Vector2(X_SIZE/2, 0), Vector2(X_SIZE/2, Y_SIZE), background_color, GRAPH_WIDTH)
	
	for index in range(0, X_SIZE):
		var current_step: int = index * PIXEL_STEP
		var x: int = current_step - MAXIMUM_RANGE/(2*PIXEL_STEP)
		draw_line(Vector2(current_step,0), Vector2(current_step, Y_SIZE), background_color, LINE_WIDTH)
		draw_line(Vector2(current_step, Y_SIZE/2 - Y_SIZE/100), Vector2(current_step, Y_SIZE/2 + Y_SIZE/100), background_color, AXIS_WIDTH)
		draw_line(Vector2(0, current_step), Vector2(X_SIZE, current_step), background_color, LINE_WIDTH)
		draw_line(Vector2(X_SIZE/2 - X_SIZE/100, current_step), Vector2(X_SIZE/2 + X_SIZE/100, current_step), background_color, AXIS_WIDTH)

func draw_current_graph():
	if current_function_name == "":
		return
	var last_position: Vector2
	var has_graphed: bool = false 
	var graph_range: Array = range(CalculatorSettings.graph_minimum/FUNCTION_ACCURACCY, CalculatorSettings.graph_maximum/FUNCTION_ACCURACCY)
	for x: float in graph_range:
		x *= FUNCTION_ACCURACCY
		var y: float = -CalculatorFunctions.fun(current_function_name, x)
		var point_position: Vector2 = Vector2(X_SIZE/2 + x * PIXEL_STEP, Y_SIZE/2 + y * PIXEL_STEP)
		if not has_graphed:
			draw_line(point_position, point_position, graph_color, GRAPH_WIDTH)
			last_position = point_position
			has_graphed = true
		else:
			draw_line(last_position, point_position, graph_color, GRAPH_WIDTH)
			last_position = point_position
