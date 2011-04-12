package aj.puzzles.naming;

/**
 * "Never call override-able methods in constructor"
 * 
 * Instantiation of Circle will invoke super constructor. Since myName is
 * overridden (& instance being created is of type Circle), it will call
 * Circle's myName. However, the radius field is not yet initialized.
 * 
 */

// What's the output of the following program?
public class Override1 {

    public static void main(String[] args) {
	System.out.println(new Circle(5));
    }
}

class Circle extends Shape {
    private final int radius;

    Circle(int radius) {
	super();
	this.radius = radius;
    }

    protected String myName() {
	return "Circle, Radius is - " + radius;
    }

}

class Shape {
    private final String name;

    Shape() {
	name = myName();
    }

    protected String myName() {
	return "Shape";
    }

    public final String toString() {
	return name;
    }
}