extends Control

@onready var calculator: Calculator = $Calculator
@onready var functions_display: Window = $FunctionsDisplay
@onready var graph_settings: Control = $GraphSettings
@onready var Show_Graph_Settings: Button = $SettingsContainer/ShowGraphSettings
@onready var Show_Calculator: Button = $WindowsContainer/ShowCalculator
@onready var Show_Functions: Button = $WindowsContainer/ShowFunctionsDisplay

func _on_show_graph_settings_pressed() -> void:
	calculator.visible = false
	functions_display.visible = false
	graph_settings.visible = true

func _on_show_calculator_pressed() -> void:
	calculator.visible = true

func _on_show_functions_display_pressed() -> void:
	functions_display.visible = true
