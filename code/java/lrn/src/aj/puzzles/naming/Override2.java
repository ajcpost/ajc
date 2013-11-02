package aj.puzzles.naming;

/**
 * "Static methods are bound compile time, not dynamically"
 * 
 * Since d2 is declared of type Duck, it selects super class's method and hence
 * displays quack. Thus overriding does not work here.
 * 
 */

// What's the output of the following program?
public class Override2 {
    public static void main(String args[]) {
	Duck d1 = new Duck();
	Duck d2 = new SilentDuck();
	d1.quack();
	d2.quack();
    }
}

class Duck {
    public static void quack() {
	System.out.print("quack ");
    }
}

class SilentDuck extends Duck {
    public static void quack() {
    }
}
