extends Control

@export var window_items: Array[Window]

@onready var numerical_settings: VBoxContainer = $Body/NumericalSettings

func _ready() -> void:
	for number_setting: Node in numerical_settings.get_children():
		var spin_box: SpinBox = number_setting.get_node("SpinBox")
		var setting_name = number_setting.name.to_snake_case()
		spin_box.value_changed.connect(on_number_setting_changed.bind(setting_name))

func _on_exit_pressed() -> void:
	visible = false
	for item: Window in window_items:
		item.visible = true

func on_number_setting_changed(value: float, setting_name: String) -> void:
	CalculatorSettings.set(setting_name, value)
	
