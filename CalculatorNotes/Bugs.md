
# Type error when parsing
7/16
The quotient of two integers when parsing is round to an integer
**7/16 fixed** Before parsing I multiply expressions by 1.0 to make the engine evaluate the integers as floats and therefore output a float value.
# Graphing asymptotes lines
7/16
When graphing functions that go to infinity in an x_value that isn't calculated, we get the last x position to connect with the next one. For example, tanx has many black lines in the asymptotes. They're ugly. My idea is to analyze the graph through their slopes.

# Limit method oscillation inaccuracy
7/17
lim() method while returns DNE for sin(1/x) still returns an arbitrary number for cos(1/x), It can't detect oscillations.
**7/16 fixed** after checking if the right and left approach agree, we find the difference of them to another left and right approaching value respectively at a smaller displacement of h. If this difference is too large on either left or right, it means that the function is probably oscillating due to the miniscule change of h. Due to how h decreases with functions at higher slopes, this doesn't mark exponentials as oscillations! (unless the slope is way too high and max_limit_attempts setting is low)

>`# check for oscillations`
	`h/= 10`
	`var left_approach2: float = fun(function_name, x_approached - h)`
	`var right_approach2: float = fun(function_name, x_approached + h)`
	`var left_difference: float = abs(left_approach - left_approach2)`
	`var right_difference: float = abs(right_approach - right_approach2)`
	`if left_difference > tolerance or right_difference > tolerance:`
		`return "DNE"`