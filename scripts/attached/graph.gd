extends Node2D
class_name Primary_Graph
# general constants
const SCALE: int = CalculatorSettings.SCALE
const FUNCTION_ACCURACY: float = 0.01
const MINIMUM_RANGE: int = -50
const MAXIMUM_RANGE: int = 50

const GRAPH_WIDTH: int = 5

const Y_SIZE: float = CalculatorSettings.Y_SIZE
const X_SIZE: float= CalculatorSettings.X_SIZE

const LINE_LENGTH_TOLERANCE: float = 5000.0
const COORDINATE_COLOR: Color = Color.BLACK
var FONT: Font = ThemeDB.fallback_font

var graph_color: Color = Color.BLACK

var current_visual_index: int
var empty_visual: Visual = Visual.new()
var second_graph_name: String 

@export var target_calculator: Calculator 
@export var visualize_button: OptionButton
@export var limit_visual: Visual
@export var derivative_visual: Visual
@export var integral_visual: Visual
@export var spatial_integral_visual: Visual

@onready var visual_list: Array[Visual] = [
	empty_visual,
	limit_visual,
	derivative_visual,
	integral_visual,
	spatial_integral_visual,
]
@onready var visual_layer: Node2D = $VisualLayer

var current_function_name: String 

func _ready() -> void:
	empty_visual.graph_controller = self
	limit_visual.graph_controller = self
	derivative_visual.graph_controller = self
	integral_visual.graph_controller = self
	spatial_integral_visual.graph_controller = self
	target_calculator.graph_function.connect(on_graph)
	visualize_button.item_selected.connect(on_visualize_changed)
	queue_visuals()
	queue_redraw()

func position_to_graph(x: float, y: float) -> Vector2:
	var scaled_position: Vector2 = Vector2(x, y) * SCALE
	return Vector2(scaled_position.x + X_SIZE/2, -scaled_position.y + Y_SIZE/2)

func _draw() -> void:
	if current_function_name == "":
		return
	draw_graph(current_function_name) 
	#visual_list[current_visual_index].visual_draw.call()

func queue_visuals() -> void:
	if current_function_name == "":
		return
	visual_layer.queue_redraw()
	
func on_graph(function_name: String) -> void:
	current_function_name = function_name
	CalculatorSettings.current_function_name = function_name
	queue_redraw()
	
func draw_graph(function_name: String) -> void:
	var last_position: Vector2
	var skip_line: bool = true 
	var minimum: float = CalculatorSettings.graph_minimum/FUNCTION_ACCURACY
	var maximum: float = CalculatorSettings.graph_maximum/FUNCTION_ACCURACY
	var graph_range: Array = range(minimum, maximum)
	for x: float in graph_range:
		x *= FUNCTION_ACCURACY
		var y: Variant = CalculatorFunctions.fun(function_name, x)
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
	visual_list[current_visual_index].on_visual_exit.call()
	current_visual_index = index
	visual_list[index].on_visual_entered.call()

func hide_all_visualizers() -> void:
	limit_visual.visible = false
	derivative_visual.visible = false
	integral_visual.visible = false
	spatial_integral_visual.visible = false

func reset_visuals() -> void:
	hide_all_visualizers()
	queue_visuals()

func visualize_nothing() -> void:
	pass
