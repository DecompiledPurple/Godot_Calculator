extends Node

var expression: Expression = Expression.new()
var math_functions: Dictionary[String, String] = {
	"test" = "(x**2-4)/(x-2)"
	}
#var function_variables: Dictionary[String, String]

var is_taking_input: bool = false

func _ready() -> void:
	pass

func function_that_returns_3() -> Variant:
	return 3

func lim(function_name: String, x_approached: Variant):
	var h: float = 0.01
	var index: int = 0
	var tolerance: float = 0.01
	# might have to error check x
	if x_approached is String:
		x_approached = x_approached.to_float()
	var left_approach: float = fun(function_name, x_approached - h)
	var right_approach: float = fun(function_name, x_approached + h)
	var difference: float = abs(left_approach - right_approach)
	#print("left: " + str(left_approach) + " right: " + str(right_approach) + " average: " + str(average) + " difference: " + str(difference) + "index: " + str(index))
	while difference > tolerance and index < CalculatorSettings.max_limit_attempts:
		index += 1 
		h /= 10
		left_approach = fun(function_name, x_approached - h)
		right_approach = fun(function_name, x_approached + h) 
		difference = abs(left_approach - right_approach)
	var average: float = (right_approach + left_approach)/2
	var result: float = round(average * 1000)/1000
	if difference <= tolerance:
		return result
	else:
		return "DNE"

func fun(function_name: String, input: Variant) -> Variant:
	if not is_taking_input:
		var error1: Error = expression.parse(str(input) + "* 1.0")
		if not error1 == OK:
			input = 0
		else:
			input = expression.execute([], self)
	var function_content: String
	if math_functions.has(function_name):
		function_content = math_functions[function_name]
	else:
		function_content = function_name 
	# it seems like we can't parse two functions that are nested in one. Might need to make a custom parser for them soon
	# check for func second argument and replace x
	function_content = function_content.replace("\"x\"", "\"" + str(input) + "\"")
	var error2: Error = expression.parse(function_content + "*1.0", ["x"])
	if not error2 == OK:
		print("error in parsing inserted function")
		return "error"
	else:
		var output = expression.execute([input], self)
		return output

func round_to_placement(x:float, decimal_placement: int) -> float:
	return round(x * 10**decimal_placement)/(10**decimal_placement)
