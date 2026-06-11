extends Window

@export var target_calculator: Calculator

var function_screen_scene = preload("res://function_screen.tscn")

@onready var screens: VBoxContainer = $ScrollContainer/Screens

func _ready():
	target_calculator.new_function.connect(on_new_function)
	target_calculator.insert_function.connect(on_insert_function)

func on_new_function(name: String, content: String) -> void:
	if screens.has_node(name):
		screens.get_node(name).queue_free()
	var new_function_screen: FunctionScreen  = function_screen_scene.instantiate()
	new_function_screen.name = name
	new_function_screen.content = content
	new_function_screen.get_node("FunctionName").text = name + "(x) = "
	new_function_screen.get_node("ScrollContainer/Screen").text = content
	new_function_screen.edit_pressed.connect(on_edit_function)
	screens.add_child(new_function_screen)

func on_edit_function(function_name: String, content: String) -> void:
	if screens.has_node(function_name):
		var function_screen: FunctionScreen = screens.get_node(function_name)
		var new_content: String = await target_calculator.take_input(function_name + "(x)", function_screen.content)
		function_screen.change_content(new_content)

func on_insert_function(function_name: String, input_value: float) -> void:
	if screens.has_node(function_name):
		var function_screen: FunctionScreen = screens.get_node(function_name)
		var input_expression: String = "(" + function_screen.content + ")"
		var error: Variant = target_calculator.expression.parse(input_expression, ["x"])
		if not error == OK:
			print("oh shoot")
		else:
			var result: Variant = target_calculator.expression.execute([input_value])
			target_calculator.used_screen.text = "=" + str(result)
		#target_calculator.used_screen.text += function_name + "(" + str(input_value) + ")"
		# make a system to pass individual functions for multi-function use
		
		#target_calculator.used_screen.text += "(" + function_screen.content + ")"
	else:
		target_calculator.used_screen.text += "0"
