extends Camera3D

const MOVE_SPEED: float = 0.1
const MOUSE_SENSITIVITY: float = 0.01
const MOVE_SPEED_MULTIPLIER: float = 0.5

var movement_global: bool = false
var moving_slow: bool = false
@export var calculator_viewport: Window

func _ready() -> void:
	pass # Replace with function body.

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
			
