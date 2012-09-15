package aj.effectivej.reflection;

import java.util.Set;
import java.util.Arrays;

public class DynamicInstantiation {
	
	public static void main(String[] args) {
		
		if (args.length < 2) {
			System.out.println("Usage: <Set class (e.g. java.util.TreeSet, java.util.HashSet)> <one or more strings>");
			System.exit (-1);
		}
	    // Translate the class name into a Class object
	    Class<?> cl = null;
	    try {
	        cl = Class.forName(args[0]);
	    } catch(ClassNotFoundException e) {
	        System.err.println("Class not found.");
	        System.exit(1);
	    }

	    // Instantiate the class
	    Set<String> s = null;
	    try {
	        s = (Set<String>) cl.newInstance();
	    } catch(IllegalAccessException e) {
	        System.err.println("Class not accessible.");
	        System.exit(1);
	    } catch(InstantiationException e) {
	        System.err.println("Class not instantiable.");
	        System.exit(1);
	    }
	    
	    // Exercise the set
	    s.addAll(Arrays.asList(args).subList(1, args.length));
	    System.out.println(s);


}
}
