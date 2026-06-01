extends Window

# paranthesis expressions aren't treated as multiplication

var buttons: Array[Button]
var special_buttons : Dictionary[String, Callable] = {
	"Evaluate" : on_equals_pressed,
	"AllClear" : on_all_clear_pressed,
	"Basic" : on_basic_operations_pressed,
	"Special" : on_special_operations_pressed,
	"RootOf" : on_root_of_pressed,
}
var keyboard_shortcuts : Dictionary[String, Callable] = {
	"\n" : on_equals_pressed,
	"=" : on_equals_pressed,
}

var expression = Expression.new()
var screen_scene = preload("res://screen.tscn")
signal evaluate

@onready var display: ScrollContainer = $Display
@onready var used_screen : TextEdit = $Display/VBoxContainer/Screen
@onready var scrollbar : VScrollBar = display.get_v_scroll_bar()
@onready var basic_operations : Control = $BasicOperations
@onready var special_operations : Control = $SpecialOperations

var last_answer: Variant
var last_scroll_length: float = 0
var is_taking_input: bool = false
var current_input_name: String

# general use

func _ready() -> void:
	append_descendant_buttons(basic_operations)
	append_descendant_buttons(special_operations)
	append_descendant_buttons($SectionButtons)
	
	for button in buttons:
		if special_buttons.has(button.name):
			button.pressed.connect(special_buttons[button.name])
		else:
			button.pressed.connect(on_button_pressed.bind(button.text))
	
	used_screen.text_changed.connect(on_text_changed)
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
	display.scroll_vertical = scrollbar.max_value
	
func on_button_pressed(key: String) -> void:
	used_screen.text += key

func create_screen() -> void:
	var new_screen : TextEdit = screen_scene.instantiate()
	$Display/VBoxContainer.add_child(new_screen)
	new_screen.grab_focus()
	used_screen.disconnect("text_changed", on_text_changed)
	used_screen.editable = false
	used_screen = new_screen
	used_screen.text_changed.connect(on_text_changed)

func take_input(varName: String) -> float:
	#complex input operations can't be stacked
	var former_screen: TextEdit = used_screen
	create_screen()
	var new_input_screen: TextEdit = used_screen
	new_input_screen.add_theme_color_override("background_color", Color.DIM_GRAY)
	new_input_screen.add_theme_color_override("font_color", Color.WHITE)
	is_taking_input = true
	new_input_screen.text = varName + "="
	new_input_screen.set_caret_column(new_input_screen.text.find("=")+1)
	
	var input: Variant = await evaluate
	#account for errors and all clear
	new_input_screen.queue_free()
	used_screen = former_screen
	former_screen.editable = true
	former_screen.text_changed.connect(on_text_changed)
	former_screen.grab_focus()
	
	if input is float or input is int:
		is_taking_input = false
		return input
	else:
		input = await take_input(varName)
		return input

func on_text_changed() -> void:
	for shortcut in keyboard_shortcuts:
		if used_screen.text.contains(shortcut):
			if shortcut == "=" and is_taking_input:
				continue
			used_screen.text = used_screen.text.replace(shortcut,"")
			keyboard_shortcuts[shortcut].call()

func close_all_sections() -> void:
	basic_operations.visible = false
	special_operations.visible = false

# operation display switching

func on_basic_operations_pressed() -> void:
	close_all_sections()
	basic_operations.visible = true

func on_special_operations_pressed() -> void:
	close_all_sections()
	special_operations.visible = true

# button operations

func on_equals_pressed() -> void:
	var evaluation_screen: TextEdit = used_screen
	if is_taking_input:
		var cut_index: int = evaluation_screen.text.find("=")
		evaluation_screen.text = evaluation_screen.text.substr(cut_index+1)
	else:
		create_screen()
		
	var error : Error = expression.parse(evaluation_screen.text)
	if error != OK:
		evaluation_screen.text = expression.get_error_text()
		evaluate.emit(expression.get_error_text())
	else:
		last_answer = expression.execute()
		evaluation_screen.text += " = " + str(last_answer)
		evaluate.emit(last_answer)
	

func on_all_clear_pressed() -> void:
	if is_taking_input:
		return
	for child in $Display/VBoxContainer.get_children():
		if child is TextEdit:
			
			#$Display/VBoxContainer.remove_child(child)
			child.queue_free()
	create_screen()

func on_root_of_pressed() -> void:
	var x: float = await take_input("x")
	var n: float = await  take_input("n")
	used_screen.text += "pow(" + str(x) + ", 1.0/" + str(n) + ")"
