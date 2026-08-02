extends Control

class_name Visual

var FONT: Font = CalculatorSettings.FONT
const COORDINATE_COLOR: Color = CalculatorSettings.COORDINATE_COLOR

var h_variable: float
var n_variable: float

var visual_draw: Callable = Callable(self, "empty_callable")
var on_visual_entered: Callable = Callable(self, "empty_callable")

func position_to_graph(x: float, y: float) -> Vector2:
	var SCALE = CalculatorSettings.SCALE
	var Y_SIZE = CalculatorSettings.Y_SIZE
	var X_SIZE = CalculatorSettings.X_SIZE
	var scaled_position: Vector2 = Vector2(x, y) * SCALE
	return Vector2(scaled_position.x + X_SIZE/2, -scaled_position.y + Y_SIZE/2)

func empty_callable() -> void:
	pass
