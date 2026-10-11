extends Node2D

const SCALE: float = CalculatorSettings.SCALE
const X_SIZE: float = CalculatorSettings.X_SIZE
const Y_SIZE: float = CalculatorSettings.Y_SIZE

const LINE_LENGTH_TOLERANCE: float = CalculatorSettings.LINE_LENGTH_TOLERANCE
const FUNCTION_ACCURACY: float = CalculatorSettings.FUNCTION_ACCURACY
const GRAPH_WIDTH: float = CalculatorSettings.GRAPH_WIDTH

var graph_color: Color = CalculatorSettings.graph_color

@onready var parent_graph: Primary_Graph = get_parent()

var draw_current_visual: Callable

func _ready() -> void:
	pass 

func _draw() -> void:
	if CalculatorSettings.current_function_name == "":
		return
	parent_graph.visual_list[parent_graph.current_visual_index].visual_draw()
	#draw_graph(CalculatorSettings.current_function_name)

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

func position_to_graph(x: float, y: float) -> Vector2:
	var scaled_position: Vector2 = Vector2(x, y) * SCALE
	return Vector2(scaled_position.x + X_SIZE/2, -scaled_position.y + Y_SIZE/2)
