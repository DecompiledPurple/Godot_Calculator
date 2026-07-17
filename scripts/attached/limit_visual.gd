extends Control

class_name LimitVisual

const DECIMAL_POINT_ROUND: int = 3

signal h_variable_changed(new_h: float)
signal n_variable_changed(new_n: float)

@onready var h_slider: HSlider = $HSlide
@onready var h_label: Label = $HLabel
@onready var right_limit_answer: RichTextLabel = $RightLimitDisplay/HBoxContainer/Answer
@onready var left_limit_answer: RichTextLabel = $LeftLimitDisplay/HBoxContainer/Answer
@onready var main_limit_answer: RichTextLabel = $MainLimitDisplay/HBoxContainer/Answer
@onready var hide_limit_answer_button: CheckBox  = $Settings/HideLimitAnswer

var h_variable: float = 0
var n_variable: float = 0
var hide_limit_answer: bool = true
var limit_answer: Variant = 0

func _on_n_spin_box_value_changed(value: float) -> void:
	n_variable = value
	n_variable_changed.emit(value)

func _on_h_slider_value_changed(value: float) -> void:
	h_variable = 10**(-value)
	h_variable_changed.emit(h_variable)
	h_label.text = "10^(" + str(-value) + ")"

func update_left_limit_label(y_value: float) -> void:
	y_value = CalculatorFunctions.round_to_placement(y_value, DECIMAL_POINT_ROUND)
	left_limit_answer.text = str(y_value)
	
func update_right_limit_label(y_value: float) -> void:
	y_value = CalculatorFunctions.round_to_placement(y_value, DECIMAL_POINT_ROUND)
	right_limit_answer.text = str(y_value)

func update_main_limit_label(y_value: Variant) -> void:
	if not hide_limit_answer:
		main_limit_answer.text = str(y_value)
	limit_answer = y_value

func _on_hide_limit_answer_pressed() -> void:
	hide_limit_answer = hide_limit_answer_button.button_pressed
	if hide_limit_answer:
		main_limit_answer.text = "?"
	else: 
		main_limit_answer.text = str(limit_answer)
	
