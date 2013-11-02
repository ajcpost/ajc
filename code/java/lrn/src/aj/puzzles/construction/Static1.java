package aj.puzzles.construction;

/**
 * "Beware of static initialization order"
 * 
 * Static fields are initialized in two phases: (a) All fields are set to their
 * default order, in this case null, 0, 0 in that order.(b) All fields are
 * initialized in the order declared.
 * 
 * In this case, it first calls initializeIfNecessary which computes the sum and
 * sets "initialized" flag to true. It however again sets back "initialized" to
 * false. So, the sum is set but boolean flag is not and hence it does double
 * addition.
 */

// What's the output of the following program?
public class Static1 {
    public static void main(String[] args) {
	System.out.println(Sum.getSum());
    }
}

class Sum {
    static {
	initIfRequired();
    }

    private static int sum;

    public static int getSum() {
	initIfRequired();
	return sum;
    }

    private static boolean initialized = false;

    private static synchronized void initIfRequired() {
	if (!initialized) {
	    for (int i = 0; i < 100; i++)
		sum += i;
	    initialized = true;
	}
    }
}