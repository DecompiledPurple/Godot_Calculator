extends Button

@export var root_node: Node

@onready var graph_settings_page: Control = root_node.get_node("GraphSettings") 
@onready var calculator: Calculator = root_node.get_node("Calculator")
@onready var functions_display: Window = root_node.get_node("FunctionsDisplay")

func _on_pressed() -> void:
	graph_settings_page.visible = true
	calculator.visible = false 
	functions_display.visible = false
