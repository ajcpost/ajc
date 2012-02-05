package com.amber.A1;

public class CheckBracket {

	private static boolean isValidManual(String expression) {
		// Indicates diff between left & right bracket count
		int balance = 0;

		for (int i = 0; i < expression.length(); i++) {
			if ('(' == expression.charAt(i)) {
				++balance;
			} else if (')' == expression.charAt(i)) {
				// Can't start an expression with right bracket
				if (balance == 0) {
					return false;
				}
				--balance;
			}
		}
		if (balance != 0) {
			return false;
		}
		return true;
	}

	private static boolean isValidRegex(String expression) {
		// TBD
		// Explore use of recursive regex to do balance bracket match.
		return true;
	}

	public static boolean isValid(String expression) {
		return isValidManual(expression);
		// return isValidRegex (expression);
	}

	public static void main(String[] args) {
		String testExpressions[] = { "(x,y)", "(x,", "(x,y))", "x(y)", "y)",
				"(x+y))(p*q)", "((x+y)*(p+q))" };

		for (int i = 0; i < testExpressions.length; i++) {
			boolean valid = isValid(testExpressions[i]);
			System.out.println("Expression " + testExpressions[i]
					+ (valid ? " : Is OK." : " : Is NOT OK."));
		}
	}
}
