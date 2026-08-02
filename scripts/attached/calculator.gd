extends Window

class_name Calculator 

# paranthesis expressions aren't treated as multiplication

var buttons: Array[Button]
var special_buttons : Dictionary[String, Callable] = {
	"Evaluate" : on_equals_pressed,
	"AllClear" : on_all_clear_pressed,
	"Basic" : on_basic_operations_pressed,
	"Special" : on_special_operations_pressed,
	"Function" : on_function_operations_pressed,
	"RootOf" : on_root_of_pressed,
	"SquareRoot" : on_square_root_pressed,
	"Log" : on_log_pressed,
	"NaturalLog" : on_natural_log_pressed,
	"BaseLog" : on_base_log_pressed,
	"Squared" : on_squared_pressed,
	"PowerOf" : on_power_of_pressed,
	"Pi" : on_pi_pressed,
	"EulersNumber" : on_eulers_number_pressed,
	"Parenthesis" : on_parenthesis_pressed,
	"Exponential" : on_exponential_pressed,
	"Clear" : on_clear_pressed,
	"Sine" : on_sine_pressed,
	"Cosine" : on_cosine_pressed,
	"Tangent" : on_tangent_pressed,
	"Arcsine" : on_arcsine_pressed,
	"Arccosine" : on_arccosine_pressed,
	"Arctangent" : on_arctangent_pressed,
	"New" : on_new_pressed,
	"Insert" : on_insert_pressed,
	"Graph" : on_graph_pressed,
	"Limit" : on_limit_pressed,
}

var keyboard_shortcuts : Dictionary[String, Callable] = {
	"\n" : on_equals_pressed,
	"=" : on_equals_pressed,
	"pi" : on_pi_pressed,
	"eu" : on_eulers_number_pressed,
}

var expression = Expression.new()
var screen_scene = preload("res://Scenes/screen.tscn")

signal _evaluate(input: String)
signal new_function(name: String, content: String)
signal insert_function(function_name: String, input_value: String)
signal graph_function(function_name: String)

@onready var display: ScrollContainer = $Display
@onready var used_screen : LineEdit = $Display/VBoxContainer/Screen
@onready var scrollbar : VScrollBar = display.get_v_scroll_bar()
@onready var basic_operations : Control = $BasicOperations
@onready var special_operations : Control = $SpecialOperations
@onready var function_operations : Control = $FunctionOperations

var skip_error_check: bool = false

var last_answer: Variant
var last_scroll_length: float = 0
var input_index: int = 0

#region General Use

func _ready() -> void:
	append_descendant_buttons(basic_operations)
	append_descendant_buttons(special_operations)
	append_descendant_buttons($SectionButtons)
	append_descendant_buttons(function_operations)
	
	for button in buttons:
		if special_buttons.has(button.name):
			button.pressed.connect(special_buttons[button.name])
		else:
			button.pressed.connect(on_button_pressed.bind(button.text))
	
	used_screen.text_changed.connect(on_text_changed)
	used_screen.text_submitted.connect(on_equals_pressed)
	scrollbar.changed.connect(on_scrollbar_changed)

func append_descendant_buttons(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
		else:
			append_descendant_buttons(child)

func on_scrollbar_changed() -> void:
	if scrollbar.max_value == last_scroll_length:
		return
	last_scroll_length = scrollbar.max_value
	@warning_ignore("narrowing_conversion")
	display.scroll_vertical = scrollbar.max_value
	
func on_button_pressed(key: String) -> void:
	used_screen.text += key
	used_screen.grab_focus()


func on_text_changed(_text_added: String) -> void:
	for shortcut in keyboard_shortcuts:
		if used_screen.text.contains(shortcut):
			if shortcut == "=" and CalculatorFunctions.is_taking_input:
				continue
			used_screen.text = used_screen.text.replace(shortcut,"")
			keyboard_shortcuts[shortcut].call()
#endregion

#region Display
func close_all_sections() -> void:
	basic_operations.visible = false
	special_operations.visible = false
	function_operations.visible = false

func on_basic_operations_pressed() -> void:
	close_all_sections()
	basic_operations.visible = true

func on_special_operations_pressed() -> void:
	close_all_sections()
	special_operations.visible = true

func on_function_operations_pressed() -> void:
	close_all_sections()
	function_operations.visible = true

func skip_to_end_line() -> void:
	used_screen.set_caret_column(used_screen.text.length())

func create_screen() -> void:
	var new_screen : LineEdit = screen_scene.instantiate()
	$Display/VBoxContainer.add_child(new_screen)
	new_screen.grab_focus()
	used_screen.disconnect("text_changed", on_text_changed)
	used_screen.disconnect("text_submitted", on_equals_pressed)
	used_screen.editable = false
	used_screen = new_screen
	used_screen.text_changed.connect(on_text_changed)
	used_screen.text_submitted.connect(on_equals_pressed)

func take_input(var_name: String, skip_error_handling: bool = false, override_content: String = "") -> String:
	var former_screen: LineEdit = used_screen
	input_index += 1
	var index = input_index
	CalculatorFunctions.is_taking_input = true
	if skip_error_handling:
		skip_error_check = true
	
	create_screen()
	var new_input_screen: LineEdit = used_screen
	var style_box: StyleBox = StyleBoxFlat.new()
	style_box.bg_color = Color.WEB_GRAY
	new_input_screen.add_theme_stylebox_override("focus", style_box)
	new_input_screen.add_theme_stylebox_override("normal", style_box)
	new_input_screen.add_theme_color_override("font_color", Color.WHITE)
	new_input_screen.set_caret_column(new_input_screen.text.find("=") + 1)
	
	new_input_screen.text = var_name + "=" 
	new_input_screen.text += override_content
	skip_to_end_line()
	
	var input: String = await _evaluate
	while index != input_index:
		input = await _evaluate
	
	input_index -= 1
	new_input_screen.queue_free()
	used_screen = former_screen
	former_screen.editable = true
	former_screen.text_changed.connect(on_text_changed)
	former_screen.text_submitted.connect(on_equals_pressed)
	former_screen.grab_focus()
	
	if not input == "error" or skip_error_handling:
		if input_index == 0:
			CalculatorFunctions.is_taking_input = false
			skip_error_check = false
		return input
	else:
		#assume error or nothing inputed
		input = await take_input(var_name)
		return input

func parse_expression(text_input: String) -> Variant:
	text_input = "1.0 * " + text_input
	# we multiply by a float to avoid rounding errors when dividing two integers
	var error: Error = expression.parse(text_input)
	if not error == OK:
		return expression.get_error_text()
	else:
		var answer: Variant = expression.execute([], CalculatorFunctions)
		return answer
#endregion

#region Button Operations
func on_equals_pressed(text_input: String = used_screen.text) -> void:
	var evaluation_screen: LineEdit = used_screen
	if CalculatorFunctions.is_taking_input:
		var cut_index: int = text_input.find("=")
		text_input = text_input.substr(cut_index+1)
	else:
		create_screen()
	
	if not skip_error_check:
		var answer: Variant = parse_expression(text_input)
		if answer is String:
			evaluation_screen.text = answer
			_evaluate.emit("error")
		else:
			last_answer = answer
			_evaluate.emit(text_input)
			evaluation_screen.text = "= " + str(answer)
	else:
			_evaluate.emit(text_input)
	skip_to_end_line()

func on_all_clear_pressed() -> void:
	if CalculatorFunctions.is_taking_input:
		return
	for child in $Display/VBoxContainer.get_children():
		if child is LineEdit:
			child.queue_free()
	create_screen()

func on_clear_pressed() -> void:
	if CalculatorFunctions.is_taking_input:
		var input_text_index: int = used_screen.text.find("=")
		used_screen.text = used_screen.text.substr(0, input_text_index + 1)
	else:
		used_screen.text = ""

func on_root_of_pressed() -> void:
	var x: String = await take_input("x")
	var n: String = await  take_input("n")
	used_screen.text += "pow(" + x + ", 1.0/(" + n + "))"
	skip_to_end_line()

func on_square_root_pressed() -> void:
	var x: String = await take_input("x")
	used_screen.text += "sqrt(" + x + ")"
	skip_to_end_line()

func on_log_pressed() -> void:
	var x: String = await take_input("x")
	used_screen.text += "(log(" + x + ")/log(10))"
	skip_to_end_line()	

func on_natural_log_pressed() -> void:
	var x: String = await take_input("x")
	used_screen.text += "log(" + x + ")"
	skip_to_end_line()
	
func on_base_log_pressed() -> void:
	var x: String = await take_input("x")
	var n: String = await take_input("n")
	used_screen.text += "(log(" + x + ")/log(" + n + "))"
	skip_to_end_line()

func on_squared_pressed() -> void:
	var x: String = await take_input("x")
	used_screen.text += "(" + x + ")**2"
	skip_to_end_line()

func on_power_of_pressed() -> void:
	var x: String = await take_input("x")
	var n: String = await take_input("n")
	used_screen.text += "(" + x + ")**" + n
	skip_to_end_line()

func on_pi_pressed() -> void:
	used_screen.text += "PI"
	used_screen.grab_focus()
	skip_to_end_line()

func on_eulers_number_pressed() -> void:
	used_screen.text += "exp(1)"
	used_screen.grab_focus()
	skip_to_end_line()

func on_exponential_pressed() -> void:
	var n: String = await take_input("n")
	used_screen.text += "exp(" + n + ")"
	skip_to_end_line()

func on_parenthesis_pressed() -> void:
	used_screen.text += "()"
	used_screen.grab_focus()
	used_screen.set_caret_column(used_screen.text.length() - 1)

func on_sine_pressed() -> void:
	var x: String = await take_input("x")
	used_screen.text += "sin(" + x + ")"
	skip_to_end_line()

func on_cosine_pressed() -> void:
	var x: String = await take_input("x")
	used_screen.text += "cos(" + x + ")"
	skip_to_end_line()

func on_tangent_pressed() -> void:
	var x: String = await take_input("x")
	used_screen.text += "tan(" + x + ")"
	skip_to_end_line()

func on_arcsine_pressed() -> void:
	var x: String = await take_input("x")
	used_screen.text += "asin(" + x + ")"
	skip_to_end_line()

func on_arccosine_pressed() -> void:
	var x: String = await take_input("x")
	used_screen.text += "acos(" + x + ")"
	skip_to_end_line()

func on_arctangent_pressed() -> void:
	var x: String = await take_input("x")
	used_screen.text += "atan(" + x + ")"
	skip_to_end_line()

func on_new_pressed() -> void:
	var skip_errors: bool = true
	var function_name: String = await take_input("function name", skip_errors)
	var contents: String = await take_input(function_name + "(x)", skip_errors)
	new_function.emit(function_name, contents)

func on_insert_pressed() -> void:
	var skip_errors: bool = true
	var function_name: String = await take_input("function name", skip_errors)
	var input_calculation: String = await take_input(function_name + "(x) -> x", skip_errors)
	insert_function.emit(function_name, input_calculation)

func on_graph_pressed() -> void:
	var skip_errors: bool = true
	var function_name: String = await take_input("function name", skip_errors)
	graph_function.emit(function_name)

func on_limit_pressed() -> void:
	var skip_errors: bool = true
	var function_name: String = await take_input("function name", skip_errors)
	var n: String = await take_input("n")
	used_screen.text = "lim(\"" + function_name + "\",\"" + n + "\")"
	skip_to_end_line()

#endregion


func _on_close_requested() -> void:
	visible = false
