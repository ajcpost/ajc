package aj.puzzles.flowofcontrol;

/**
 * "Finally is not executed for system.exit()"
 * 
 * Finally is always executed whether try completes normally or abnormally.
 * However, this doesn't hold true when system.exit is called. Hence the 2nd
 * println will never display.
 */

// What's the output of the following program?
public class Finally1 {
    public static void main(String[] args) {
	try {
	    System.out.println("Hello world");
	    System.exit(0);
	} finally {
	    System.out.println("I said Hello world");
	}
    }
}