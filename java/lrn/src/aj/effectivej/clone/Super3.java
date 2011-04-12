package aj.effectivej.clone;

class Super3 extends Super2 {

    @Override
    public Super3 clone() throws CloneNotSupportedException {
	System.out.println("In Super3 clone: ");
	Object result = super.clone();
	System.out.println("           " + result.getClass());
	return (Super3) result;
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
	// TODO Auto-generated method stub

	try {
	    System.out.println("Creating object..");
	    Super3 s1 = new Super3();
	    System.out.println("Cloning object..");
	    Super3 s2 = (Super3) s1.clone();
	} catch (Exception e) {
	    System.out.println(e.toString());
	}

    }
}