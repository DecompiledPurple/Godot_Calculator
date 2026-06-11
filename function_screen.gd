extends ColorRect

class_name FunctionScreen

@export var content: String

signal delete_pressed()
signal edit_pressed(name: String, content: String)

@onready var options: AspectRatioContainer = $Options
@onready var edit_button: Button = $Options/HBoxContainer/Edit
@onready var delete_button: Button = $Options/HBoxContainer/Edit
@onready var screen: LineEdit = $ScrollContainer/Screen

func _on_edit_pressed() -> void:
	edit_pressed.emit(name, content)

func _on_delete_pressed() -> void:
	delete_pressed.emit()
	queue_free()

func _on_mouse_entered() -> void:
	options.visible = true

func _on_mouse_exited() -> void:
	options.visible = false

func change_content(new_content: String) -> void:
	content = new_content
	screen.text = new_content
