# Parse_calc
Instead of splitting into tokens which makes this more complex, It would be easier if I validate a sequence repeatedly while evaluating the input.

## Sequence
* Expect a numerical value (if not, raise an error)
* Expect a valid symbol after a space
* Expect another numerical value (if not, raise an error)
* Expect a valid symbol after a space
* Repeat until completion.

If at any point the sequence is not as expected, simply raise an error. If we do not have the error flag set and we complete parsing the string, we report back the value. If error flag is not set but there's no input, we return whatever calculation we currently have.

**DO NOT** support anything but integers - for one, it simplifies this problem and most importantly, I'm not confident with floating point assembly instructions.

# Printing and digit limits (later expansion if interested)
* Use EDX:EAX to exceed 10^9 limit.
* Use inverse_print and modulo to perform right-to-left integer conversion and inverse_print to print in reverse order.