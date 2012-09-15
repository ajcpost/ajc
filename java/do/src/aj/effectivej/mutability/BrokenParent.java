package aj.effectivej.mutability;

// Class not final, method not final.
public class BrokenParent {
	private final int value;
	public int getValue () {
		return value;
	}
	public BrokenParent (int val) {
		value = val;
	}
	
	public static void main(String[] args) {

		// Client expects value 10
		BrokenParent p = new BrokenParent (10);
		System.out.println ("Value:" + p.getValue());

	}
}
