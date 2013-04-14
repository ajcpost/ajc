package aj.puzzles.flowofcontrol;

/**
 * "Never use exception to continue loop"
 * 
 * The problem here is with use of '&' instead of '&&' in the
 * thirdElementIsThree test. This operator is overloaded for two boolean operand
 * but will evaluate both the conditions unlike '&&' which will stop if first
 * condition evaluates to false. Thus for arrays having less than 3 elements it
 * results in ArrayIndexOutOfBoundsException.
 * 
 * The real problem is that this exception is silently swallowed in the
 * try-catch block and program silently produces incorrect result.
 */

// Program aim is to display how many int arrays have a negative 3rd element.
public class Loop1 {
    public static void main(String[] args) {
	int[][] tests = { { 2, 3, 1, 0, 5 }, { 7, 8 }, { 1, 2, -10 },
		{ 100, 50, -1, 10 }, { 9 } };
	int successCount = 0;

	try {
	    int i = 0;
	    while (true) {
		if (thirdElementNegative(tests[i++]))
		    successCount++;
	    }
	} catch (ArrayIndexOutOfBoundsException e) {
	}
	System.out.println(successCount);
    }

    private static boolean thirdElementNegative(int[] a) {
	return a.length >= 3 & a[2] < 0;
    }
}
