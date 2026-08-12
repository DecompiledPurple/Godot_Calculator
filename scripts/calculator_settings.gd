extends Node

const SCALE: int = 25
const Y_SIZE: int = 1000
const X_SIZE: int = 1000
var FONT: Font = ThemeDB.fallback_font
const COORDINATE_COLOR: Color = Color.BLACK

var current_function_name: String
var visualization_index: int = 0

var graph_maximum: int = 10
var graph_minimum: int = -10
var max_limit_attempts: int = 10
var special_graph_color: Color = Color.BLUE
var integral_iterations: int = 100

func position_to_graph(x: float, y: float) -> Vector2:
	var scaled_position: Vector2 = Vector2(x, y) * SCALE
	return Vector2(scaled_position.x + X_SIZE/2, -scaled_position.y + Y_SIZE/2)
