package aj.effectivej.mutability;

public class MaliciousChild extends BrokenParent {

    public MaliciousChild(int val) {

	// Can ignore the passed value and substitute with another number.
	super(5);
    }

    // Can return another value if allowed to override the method.
    @Override
    public int getValue() {
	return 5;
    }

    public static void main(String[] args) {

	// Client expects value 10
	BrokenParent p = new MaliciousChild(10);
	System.out.println("Value:" + p.getValue());

    }

}
