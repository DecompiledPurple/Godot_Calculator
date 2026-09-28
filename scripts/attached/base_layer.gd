extends Node2D


const Y_SIZE: int = CalculatorSettings.Y_SIZE
const X_SIZE: int = CalculatorSettings.X_SIZE
const SCALE: int = CalculatorSettings.SCALE
const GRAPH_WIDTH: int = 5
const AXIS_WIDTH: int = 3
const LINE_WIDTH: int = 2

var background_color: Color = Color.BLACK
var graph_color: Color = Color.BLACK


func _ready() -> void:
	queue_redraw()

func _process(_delta: float) -> void:
	pass

func _draw() -> void:
	draw_base_graph()

func draw_base_graph() -> void:
	#draw_circle(Vector2.ZERO, 200, background_color, true)
	# draw_circle(Vector2(500,500), 50, Color.REBECCA_PURPLE)
	draw_line(Vector2(0, Y_SIZE/2), Vector2(X_SIZE, Y_SIZE/2), background_color, GRAPH_WIDTH)
	draw_line(Vector2(X_SIZE/2, 0), Vector2(X_SIZE/2, Y_SIZE), background_color, GRAPH_WIDTH)
	
	for index in range(0, X_SIZE/SCALE):
		var current_step: int = index * SCALE
		draw_line(Vector2(current_step,0), Vector2(current_step, Y_SIZE), background_color, LINE_WIDTH)
		draw_line(Vector2(current_step, Y_SIZE/2 - Y_SIZE/100), Vector2(current_step, Y_SIZE/2 + Y_SIZE/100), background_color, AXIS_WIDTH)
		draw_line(Vector2(0, current_step), Vector2(X_SIZE, current_step), background_color, LINE_WIDTH)
		draw_line(Vector2(X_SIZE/2 - X_SIZE/100, current_step), Vector2(X_SIZE/2 + X_SIZE/100, current_step), background_color, AXIS_WIDTH)
