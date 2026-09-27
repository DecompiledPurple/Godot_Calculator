extends Control

class_name Visual

var FONT: Font = CalculatorSettings.FONT
const COORDINATE_COLOR: Color = CalculatorSettings.COORDINATE_COLOR
const VISUAL_CIRCLE_SIZE: int = 8
const TEXT_SIZE = 30
const STRING_ROUND: int = 4

var graph_controller: Node2D

var visual_draw: Callable = Callable(self, "empty_callable")
var on_visual_entered: Callable = Callable(self, "on_entered")

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

func rect_to_graph(rect: Rect2) -> Rect2:
	var new_rect: Rect2 = rect
	new_rect.position = vector_to_graph(rect.position)
	new_rect.size = rect.size * CalculatorSettings.SCALE
	print(new_rect)
	return new_rect

func empty_callable() -> void:
	graph_controller.draw_circle(position_to_graph(0,0), VISUAL_CIRCLE_SIZE, Color.PURPLE, false)

func on_entered() -> void:
	visible = true
	graph_controller.queue_redraw()
