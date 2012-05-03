package aj.puzzles.execution;

/**
 * "Do not use inheritance when not appropriate.
 * 
 * "count" is static in Counter and only a single copy is shared with Dogs/Cats
 * and hence program will print 4,4 instead of 2,2. The field can not be made
 * non-static since it will make it 1 per instance.
 * 
 * The real problem is w.r.t design choice. Neither Dogs nor Cats are of type
 * Counter so inheriting it is a bad choice. Use composition.
 * 
 * 
 */

// What's the output of the following program?
public class Inherit1 {
    public static void main(String[] args) {
	Football[] fballs = { new Football(), new Football() };
	Cricketball[] cballs = { new Cricketball(), new Cricketball() };

	System.out.println(Football.getCount() + " footballs.");
	System.out.println(Cricketball.getCount() + " cricketballs.");
    }
}

class Counter {
    private static int count;

    public static void increment() {
	count++;
    }

    public static int getCount() {
	return count;
    }
}

class Football extends Counter {
    public Football() {
	increment();
    }
}

class Cricketball extends Counter {
    public Cricketball() {
	increment();
    }
}