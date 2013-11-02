package aj.puzzles.naming;

/**
 * "Overload resolution prefers most-specific match"
 * 
 * Overload resolution happens in two steps: (a) First all matching methods are
 * selected (b) the most-specific match is chosen.
 * 
 * In this case, both constructors are eligible but the one with Object is less
 * specific since it can accept any param and hence not chosen.
 * 
 */

// What's the output of the following program?
public class Overload1 {
    private Overload1(Object o) {
	System.out.println("Object");
    }

    private Overload1(double[] dArray) {
	System.out.println("double array");
    }

    public static void main(String[] args) {
	new Overload1(null);
    }
}
