extends Node2D

# general constants
const SCALE: int = 25
const FUNCTION_ACCURACCY: float = 0.01
const MINIMUM_RANGE: int = -50
const MAXIMUM_RANGE: int = 50

const GRAPH_WIDTH: int = 5
const AXIS_WIDTH: int = 3
const LINE_WIDTH: int = 2

const Y_SIZE: float = 1000
const X_SIZE: float= 1000

const LINE_LENGTH_TOLERANCE: float = 5000.0
const COORDINATE_COLOR: Color = Color.BLACK
var FONT: Font = ThemeDB.fallback_font
# visual constants
# limit visual
const LEFT_LIMIT_COLOR: Color = Color.RED
const RIGHT_LIMIT_COLOR: Color = Color.BLUE
const LIMIT_CIRCLE_SIZE: int = 5
const LIMIT_COORDINATE_OFFSET: Vector2 = Vector2(0.5,0.5) * SCALE

var background_color: Color = Color.BLACK
var graph_color: Color = Color.BLACK

var h_variable: float
var n_variable: float
var current_visual_index: int
var empty_visual: Visual = Visual.new()

@export var target_calculator: Calculator 
@export var visualize_button: OptionButton
@export var limit_visual: Visual

@onready var visual_list: Array[Visual] = [
	empty_visual,
	limit_visual,
]
var current_function_name: String 

func _ready() -> void:
	limit_visual.graph_controller = self
	
	target_calculator.graph_function.connect(on_graph)
	visualize_button.item_selected.connect(on_visualize_changed)
	queue_redraw()

func position_to_graph(x: float, y: float) -> Vector2:
	var scaled_position: Vector2 = Vector2(x, y) * SCALE
	return Vector2(scaled_position.x + X_SIZE/2, -scaled_position.y + Y_SIZE/2)

func _draw() -> void:
	draw_base_graph()
	if current_function_name == "":
		return
	draw_current_graph()
	visual_list[current_visual_index].visual_draw.call()
	
func on_graph(function_name: String) -> void:
	current_function_name = function_name
	CalculatorSettings.current_function_name = function_name
	queue_redraw()


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

func draw_current_graph() -> void:
	var last_position: Vector2
	var skip_line: bool = true 
	var minimum: float = CalculatorSettings.graph_minimum/FUNCTION_ACCURACCY
	var maximum: float = CalculatorSettings.graph_maximum/FUNCTION_ACCURACCY
	var graph_range: Array = range(minimum, maximum)
	for x: float in graph_range:
		x *= FUNCTION_ACCURACCY
		var y: Variant = CalculatorFunctions.fun(current_function_name, x)
		if y == null or y is String or is_inf(y): # implied error
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
			draw_line(last_position, point_position, graph_color, GRAPH_WIDTH)
			last_position = point_position

func on_visualize_changed(index: int) -> void:
	current_visual_index = index
	hide_all_visualizers()
	visual_list[index].on_visual_entered.call()

func hide_all_visualizers() -> void:
	limit_visual.visible = false

func reset_visuals() -> void:
	hide_all_visualizers()
	queue_redraw()

func visualize_nothing() -> void:
	pass
