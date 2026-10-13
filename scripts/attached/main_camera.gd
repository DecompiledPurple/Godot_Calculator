extends Camera3D

const MOVE_SPEED: float = 0.1
const MOUSE_SENSITIVITY: float = 0.01
const MOVE_SPEED_MULTIPLIER: float = 0.5
const DEFAULT_Z_COORDINATE: float = 4
const CAMERA_TWEEN_TIME: float = 0.5
const CAMERA_TWEEN_DIRECTION: Tween.EaseType = Tween.EaseType.EASE_OUT
const CAMERA_TRANSITION: Tween.TransitionType = Tween.TransitionType.TRANS_QUAD

var movement_global: bool = false
var moving_slow: bool = false
var geometric_points: Array[Variant]
var in_geometric_view: bool = false
var geometric_iteration_index: int = 0


@export var calculator_viewport: Window
@export var integral_visual: Integral_Visual
@export var graph_sprite: Sprite3D

func _ready() -> void:
	integral_visual.enter_geometric_view.connect(on_geometric_view_entered)
	integral_visual.update_sum_positions.connect(on_geometric_points_updated)
	integral_visual.exit_geometric_view.connect(on_geometric_view_exit)

func rotation_to_vector(x_rads, y_rads) -> Vector3:
	return Vector3(-sin(y_rads), sin(x_rads), -cos(x_rads) * cos(y_rads)) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var focus_owner: Variant = get_viewport().gui_get_focus_owner()
	if focus_owner is LineEdit and focus_owner.is_editing():
		return
	var calculator_focus: Variant = calculator_viewport.gui_get_focus_owner()
	if calculator_viewport.has_focus() and calculator_focus is LineEdit and calculator_focus.is_editing():
		return
	var movement_vector: Vector3 = Vector3.ZERO

	if Input.is_action_pressed("MOVE_FORWARD"):
		if movement_global:
			movement_vector += Vector3.FORWARD
		else:
			movement_vector += rotation_to_vector(rotation.x, rotation.y)
	if Input.is_action_pressed("MOVE_BACKWARD"):
		if movement_global:
			movement_vector += Vector3.BACK
		else:
			movement_vector += rotation_to_vector(-rotation.x, rotation.y + PI)
	if Input.is_action_pressed("MOVE_LEFT"):
		if movement_global:
			movement_vector += Vector3.LEFT
		else:
			movement_vector += rotation_to_vector(0, rotation.y + PI/2)
	if Input.is_action_pressed("MOVE_RIGHT"):
		if movement_global:
			movement_vector += Vector3.RIGHT
		else:
			movement_vector += rotation_to_vector(0, rotation.y - PI/2)
	if Input.is_action_pressed("MOVE_UP"):
		movement_vector += Vector3.UP
	if Input.is_action_pressed("MOVE_DOWN"):
		movement_vector += Vector3.DOWN
	var movement_modifier: float = MOVE_SPEED
	if moving_slow:
		movement_modifier *= MOVE_SPEED_MULTIPLIER
	position += movement_vector.normalized() * movement_modifier

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("MOVE_CAMERA"):
		rotate_x(-event.screen_relative.y * MOUSE_SENSITIVITY)
		rotate_y(-event.screen_relative.x * MOUSE_SENSITIVITY)
		# something seems to be trying to roll instead of move pitch
		rotation.z = 0
	elif event.is_action("GLOBAL_MOVEMENT_TOGGLE"):
		if movement_global:
			movement_global = false
		else:
			movement_global = true
	if event.is_action("MOVE_SLOW"):
		if moving_slow:
			moving_slow = false
		else: 
			moving_slow = true
	if not in_geometric_view: 
		return
	if event.is_action_released("GEOMETRIC_LAST"):
		geometric_iteration_index -= 1
		integral_visual.geometric_index = geometric_iteration_index
		view_geometric_point(geometric_iteration_index)
		
	elif event.is_action_released("GEOMETRIC_NEXT"):
		geometric_iteration_index += 1
		integral_visual.geometric_index = geometric_iteration_index
		view_geometric_point(geometric_iteration_index)

func on_geometric_view_entered(sum_positions: Array[Vector2]) -> void:
	geometric_points = sum_positions
	rotation = Vector3.ZERO
	in_geometric_view = true
	geometric_iteration_index = 0
	view_geometric_point(geometric_iteration_index)

func view_geometric_point(index: int):
	if geometric_points.is_empty():
		return
	if geometric_points.size() - 1 < index:
		index = 0
		geometric_iteration_index = 0
		integral_visual.geometric_index = 0
	elif 0 > index:
		index = geometric_points.size() - 1
		geometric_iteration_index = geometric_points.size() - 1
		integral_visual.geometric_index = geometric_points.size() - 1
	integral_visual.visual_layer.queue_redraw()

	var point_position: Variant = geometric_points[index]
	if point_position is Vector2:
		var camera_tween: Tween = get_tree().create_tween()
		var point_position_3d: Vector3 = vector3_to_graph(Vector3(point_position.x, point_position.y, 0)) + Vector3(0, 0, position.z)
		camera_tween.tween_property(self, "position", point_position_3d, CAMERA_TWEEN_TIME).set_trans(CAMERA_TRANSITION).set_ease(CAMERA_TWEEN_DIRECTION)

func on_geometric_points_updated(sum_positions: Array[Vector2]) -> void:
	geometric_points = sum_positions
	view_geometric_point(geometric_iteration_index)

func on_geometric_view_exit() -> void:
	in_geometric_view = false
	
func vector3_to_graph(vector: Vector3) -> Vector3:
	return vector * CalculatorSettings.SCALE * graph_sprite.pixel_size
