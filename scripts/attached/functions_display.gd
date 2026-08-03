extends Window

@export var target_calculator: Calculator

var function_screen_scene: Resource = preload("res://scenes/calculator/function_screen.tscn")
var jonkler: Array[Callable] 

@onready var screens: VBoxContainer = $ScrollContainer/Screens

func _ready():
	target_calculator.new_function.connect(on_new_function)
	target_calculator.insert_function.connect(on_insert_function)

func on_new_function(function_name: String, content: String) -> void:
	if function_name == "derivative_function":
		function_name = "f" # default to name f since we need the name for the deriv() method
	if screens.has_node(function_name):
		var function_screen: FunctionScreen = screens.get_node(function_name)
		function_screen.change_content(content)
	else:
		var new_function_screen: FunctionScreen  = function_screen_scene.instantiate()
		new_function_screen.name = function_name
		new_function_screen.get_node("FunctionName").text = function_name + "(x) = "
		new_function_screen.edit_pressed.connect(on_edit_function)
		screens.add_child(new_function_screen)
		new_function_screen.change_content(content)

func on_edit_function(function_name: String, content: String) -> void:
	if screens.has_node(function_name):
		var skip_errors: bool = false
		var function_screen: FunctionScreen = screens.get_node(function_name)
		var new_content: String = await target_calculator.take_input(function_name + "(x)", skip_errors, function_screen.content)
		function_screen.change_content(new_content)

func on_insert_function(function_name: String, input_value: String) -> void:
	if screens.has_node(function_name):
		var escaped_input_value: String = ""
		var past_char_escaped: bool = false
		# to properly escape quotations in input (only works for two nests)
		for index in range(input_value.length()): 
			if input_value[index] == "\\":
				escaped_input_value += input_value[index]
				past_char_escaped = true
			elif input_value[index] == "\"" and not past_char_escaped:
				escaped_input_value += "\\\""
				past_char_escaped = false
			else:
				escaped_input_value += input_value[index]
				past_char_escaped = false
		var input_expression: String = "fun(\"" + function_name + "\",\"" + escaped_input_value + "\")" 
		target_calculator.used_screen.text += input_expression
	else:
		target_calculator.used_screen.text += "0"


func _on_close_requested() -> void:
	visible = false
