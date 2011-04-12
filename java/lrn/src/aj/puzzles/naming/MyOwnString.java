package aj.puzzles.naming;

/**
 * "Avoid reusing the names of platform classes"
 * 
 * In this case, main method takes a parameter of String which is a user defined
 * String and not java.lang.String. Hence the program theows NoSuchMethodError.
 * 
 * Never reuse from java.lang since these names are automatically imported
 * everywhere and cause more confusion.
 * 
 */

// What's the output of the following program?
public class MyOwnString {
    
    public static void main(String[] args) {
	String s = new String("Hello world");
	System.out.println(s);
    }
}

// Un-commenting this will impact String usage in other classes in this package.
/*class String {
	private final java.lang.String s;

	public String(java.lang.String s) {
	    this.s = s;
	}

	public java.lang.String toString() {
	    return s;
	}
}*/
