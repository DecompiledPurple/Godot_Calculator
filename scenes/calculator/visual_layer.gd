extends Node2D

@onready var parent_graph: Primary_Graph = get_parent()

var draw_current_visual: Callable

func _ready() -> void:
	pass 

func _draw() -> void:
	if CalculatorSettings.current_function_name == "":
		return
	parent_graph.visual_list[parent_graph.current_visual_index].visual_draw()
	#draw_graph(CalculatorSettings.current_function_name)
