package aj.effectivej.clone;

public class Super2 extends Super1 {

    @Override
    public Super2 clone() throws CloneNotSupportedException {
	System.out.println("In Super2 clone: ");
	Object result = super.clone();
	System.out.println("           " + result.getClass());
	return (Super2) result;
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
	// TODO Auto-generated method stub

	try {
	    System.out.println("Creating object..");
	    Super2 s1 = new Super2();
	    System.out.println("Cloning object..");
	    Super2 s2 = (Super2) s1.clone();
	} catch (Exception e) {
	    System.out.println(e.toString());
	}

    }
}