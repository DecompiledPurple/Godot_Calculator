extends Visual

class_name Spatial_Integral_Visual

signal enter_geometric_view(sum_positions: Array[Vector2])
signal update_sum_positions(sum_positions: Array[Vector2])
signal exit_geometric_view()

const SOLID_COLOR1: Color = Color.BLUE
const SOLID_COLOR2: Color = Color.AQUA
const SOLID_COLOR3: Color = Color.RED
const SOLID_COLOR4: Color = Color.DEEP_PINK
const SOLID_TRANSPARENCY: float = 0.25
const SOLID_TRANSPARENCY2: float = 0.9

const VIEW_OFFSET: float = 2.5

const SQUARE_SHAPE_INDEX: int = 0
const RECTANGLE_SHAPE_INDEX: int = 1
const CIRCLE_SHAPE_INDEX: int = 2

@export var graph_sprite: Sprite3D

var boxes_used: Array[MeshInstance3D] 
var material_base: StandardMaterial3D = StandardMaterial3D.new()
var sum_positions: Array[Vector2]

var n_variable: float = 0
var b_variable: float = 1.0
var a_variable: float = 0
var direction_value: float = 0.5
var shape_index: int = 0
var height_function_name: String
var in_geometric_view: bool = false
var geometric_index: int = 0

@onready var sprite_viewport: SubViewport = graph_sprite.get_node("SubViewport")
@onready var n_spin_box: SpinBox = $VBoxContainer2/NVariable/NSpinBox
@onready var function_name_edit: LineEdit = $FunctionNameEdit
@onready var geometric_view_button: Button = $GeometricView

func  _ready() -> void:
	material_base.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_base.blend_mode = BaseMaterial3D.BLEND_MODE_ADD

func clear_boxes() -> void:
	for box: MeshInstance3D in boxes_used:
		box.free()
	boxes_used.clear()

func visual_draw() -> void:
	var delta_x: float = (b_variable - a_variable)/n_variable
	var current_function_name: String = CalculatorSettings.current_function_name
	clear_boxes()
	sum_positions.clear()
	
	if shape_index == SQUARE_SHAPE_INDEX:
		for index in range(n_variable):
			var is_square: bool = true
			draw_rectangular_prism(index, delta_x, is_square)
	elif shape_index == RECTANGLE_SHAPE_INDEX:
		for index in range(n_variable):
			draw_rectangular_prism(index, delta_x)
	elif shape_index == CIRCLE_SHAPE_INDEX:
		for index in range(n_variable):
			draw_cylinder(index, delta_x)
	if in_geometric_view:
		update_sum_positions.emit(sum_positions)
		
# find a way to stop camera movement when focused on a textbox

func draw_rectangular_prism(index: int, delta_x: float, is_square: bool = false) -> void:
	if not CalculatorFunctions.has_function(height_function_name) and not is_square:
		return
	var block: MeshInstance3D = MeshInstance3D.new()
	var block_mesh: BoxMesh = BoxMesh.new()
	var block_material: StandardMaterial3D = StandardMaterial3D.new()
	var current_function_name: String = CalculatorSettings.current_function_name
	var x: float = a_variable + delta_x * (index + direction_value)
	var corner_x: float = a_variable + delta_x * index
	var y: float = CalculatorFunctions.fun(current_function_name,  x)
	var transparency: float = SOLID_TRANSPARENCY
	sum_positions.append(Vector2(corner_x + delta_x/2 + VIEW_OFFSET, y/2)) 
	# we multiply delta by 3/2 to setup the camera in front to allow the user to orient the camera towards the cross section. 
	# I will add an automatic version of this later
	
	if not y is float:
		return
	var height: Variant # height can be considered the z axis
	if not is_square:
		height = CalculatorFunctions.fun(height_function_name, x)
		if not height is float:
			return
	else:
		height = y
	if in_geometric_view and not index == geometric_index:
		transparency = SOLID_TRANSPARENCY2
	block.transparency = transparency
	block_material.render_priority = 1
	block_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if index % 2 == 1:
		if y > 0:
			block_material.albedo_color = SOLID_COLOR1
		else: 
			block_material.albedo_color = SOLID_COLOR3
	else:
		if y > 0:
			block_material.albedo_color = SOLID_COLOR2
		else:
			block_material.albedo_color = SOLID_COLOR4

	block_mesh.material = block_material
	if height > 0:
		block.position = vector3_to_graph(Vector3(x, y/2, height/2))
	else:
		block.position = vector3_to_graph(Vector3(x, y/2, -height/2))
	block_mesh.size = vector3_to_graph(Vector3(delta_x, y, height))
	block.mesh = block_mesh
	boxes_used.append(block)
	graph_sprite.add_child(block)

func draw_cylinder(index: int, delta_x: float) -> void:
	var cylinder: MeshInstance3D = MeshInstance3D.new()
	var cylinder_mesh: CylinderMesh = CylinderMesh.new()
	var cylinder_material: StandardMaterial3D = StandardMaterial3D.new()
	var current_function_name: String = CalculatorSettings.current_function_name
	var x: float = a_variable + delta_x * (index + direction_value)
	var y: float = CalculatorFunctions.fun(current_function_name,  x)
	var corner_x: float = a_variable + delta_x * index
	var cylinder_position: Vector3 = vector3_to_graph(Vector3(x,0,0))
	var transparency: float = SOLID_TRANSPARENCY

	sum_positions.append(Vector2(corner_x + delta_x/2 + VIEW_OFFSET, y/2))

	if not y is float:
		return
	cylinder_mesh.height = point_to_graph3d(delta_x)
	cylinder_mesh.top_radius = point_to_graph3d(abs(y))
	cylinder_mesh.bottom_radius = point_to_graph3d(abs(y))
	if index & 1 > 0:
		cylinder_material.albedo_color = SOLID_COLOR1
	else:
		cylinder_material.albedo_color = SOLID_COLOR2
	if in_geometric_view and not index == geometric_index:
		transparency = SOLID_TRANSPARENCY2
	cylinder_material.render_priority = 1
	cylinder_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cylinder.transparency = transparency
	cylinder.mesh = cylinder_mesh
	cylinder.material_override = cylinder_material
	cylinder.position = cylinder_position
	cylinder.rotate_z(PI/2)
	boxes_used.append(cylinder)
	graph_sprite.add_child(cylinder)
	

func vector3_to_graph(vector: Vector3) -> Vector3:
	return vector * CalculatorSettings.SCALE * graph_sprite.pixel_size

func point_to_graph3d(point: float) -> float:
	return point * CalculatorSettings.SCALE * graph_sprite.pixel_size

func _on_direction_slider_value_changed(value: float) -> void:
	direction_value = value
	visual_layer.queue_redraw()

func _on_b_spin_box_value_changed(value: float) -> void:
	b_variable = value
	visual_layer.queue_redraw()

func _on_a_spin_box_value_changed(value: float) -> void:
	a_variable = value
	visual_layer.queue_redraw()

func _on_n_spin_box_value_changed(value: float) -> void:
	n_variable = value
	visual_layer.queue_redraw()

func _on_n_slider_value_changed(value: float) -> void:
	n_spin_box.value = value

func _on_option_button_item_selected(index: int) -> void:
	shape_index = index
	if shape_index == RECTANGLE_SHAPE_INDEX or shape_index == CIRCLE_SHAPE_INDEX:
		function_name_edit.visible = true
	else:
		function_name_edit.visible = false
	visual_layer.queue_redraw()

func _on_function_name_edit_text_submitted(new_text: String) -> void:
	height_function_name = new_text
	visual_layer.queue_redraw()

func _on_function_name_edit_editing_toggled(toggled_on: bool) -> void:
	if toggled_on:
		function_name_edit.clear()

func on_exit() -> void:
	clear_boxes()
	sum_positions.clear()
	visible = false
	if in_geometric_view:
		exit_geometric_view.emit()
		geometric_view_button.text = "Enter Geometric View"

func _on_geometric_view_pressed() -> void:
	if in_geometric_view:
		in_geometric_view = false
		geometric_view_button.text = "Enter Geometric View"
		exit_geometric_view.emit()
	else:
		in_geometric_view = true
		geometric_view_button.text = "Exit Geometric View"
		enter_geometric_view.emit(sum_positions)
