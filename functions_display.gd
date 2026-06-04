extends Window

@export var target_calculator: Calculator 

var function_screen_scene = preload("res://function_screen.tscn")

@onready var screens: VBoxContainer = $ScrollContainer/Screens

func _ready():
	target_calculator.new_function.connect(on_new_function)
	
func on_new_function(name: String, content: String):
	var new_function_screen: TextEdit  = function_screen_scene.instantiate()
	new_function_screen.get_node("FunctionName").text = name
	new_function_screen.text = content
	screens.add_child(new_function_screen)
	
