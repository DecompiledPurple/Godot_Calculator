extends Node

var calculator: Calculator
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

func lim(function_name: String, x_approached: Variant) -> Variant:
	if not math_functions.has(function_name):
		return "no function found"
	var h: float = 0.01
	var index: int = 0
	var tolerance: float = 0.01
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
	# check for oscillations
	h/= 10
	var left_approach2: float = fun(function_name, x_approached - h)
	var right_approach2: float = fun(function_name, x_approached + h)
	var left_difference: float = abs(left_approach - left_approach2)
	var right_difference: float = abs(right_approach - right_approach2)
	if left_difference > tolerance or right_difference > tolerance:
		print("DNE: oscillation")
		print("function: " + math_functions[function_name])
		calculator.send_forced_error("DNE: oscillation")
		return "DNE"
	
	var average: float = (right_approach + left_approach)/2
	var result: float = round(average * 1000)/1000
	if difference <= tolerance:
		return result
	else:
		calculator.send_forced_error("DNE")
		print("exhausted agreement process. DNE or slope is too large")
		return "DNE"

func deriv(function_name: String, input: Variant) -> Variant:
	if not math_functions.has(function_name):
		print("no function found")
		return
	# we can write out the definition of the derivative
	#math_functions["derivative_function"] = "(fun(\"" + function_name + "\"," + str(input) + ") - fun(\"" + function_name + "\"," + str(input) + " - x))/x"
	var function_string1: String = math_functions[function_name].replace("x", str(input))
	var function_string2: String = math_functions[function_name].replace("x", "(" + str(input) + " + x" + ")")
	math_functions["derivative_function"] = "((" + function_string2 + ") - (" + function_string1 + "))/x"
	
	var answer: Variant = lim("derivative_function", 0)
	return answer

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
		return "error"
	else:
		var output = expression.execute([input], self)
		return output

func round_to_placement(x:float, decimal_placement: int) -> float:
	return round(x * 10**decimal_placement)/(10**decimal_placement)
