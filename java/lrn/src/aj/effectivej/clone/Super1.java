package aj.effectivej.clone;

public class Super1 implements Cloneable {

    @Override
    public Super1 clone() throws CloneNotSupportedException {
	System.out.println("In Super1 clone: ");
	Object result = super.clone();
	System.out.println("           " + result.getClass());
	return (Super1) result;
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
	// TODO Auto-generated method stub

	try {
	    System.out.println("Creating object..");
	    Super1 s1 = new Super1();
	    System.out.println("Cloning object..");
	    Super1 s2 = (Super1) s1.clone();
	} catch (Exception e) {
	    System.out.println(e.toString());
	}

    }

}