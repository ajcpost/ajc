package aj.puzzles.construction;

import java.util.*;

/**
 * "Beware of static initialization order"
 * 
 * Static fields are initialized in two phases: (a) All fields are set to their
 * default order, in this case null, 0, 0 in that order.(b) All fields are
 * initialized in the order declared.
 * 
 * In this case, when "INSTANCE" field is getting initialized as part of step
 * (b), it calls the constructor. However, "CURRENT_YEAR" is not set and hence
 * it computes incorrect value for last year.
 */

// What would be the output of the program?
public class Static2 {

    public static final Static2 INSTANCE = new Static2();
    private final int lastYear;
    private static final int CURRENT_YEAR = Calendar.getInstance().get(
	    Calendar.YEAR);

    private Static2() {
	lastYear = CURRENT_YEAR - 1;
    }

    public int lastYear() {
	return lastYear;
    }

    public static void main(String[] args) {
	System.out.println("Last year: " + INSTANCE.lastYear());
    }
}
