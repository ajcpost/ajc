package aj.classloader;

import java.io.*;

/**
 * 
 * "src/aj/nobuild" directory has a bunch of classes compiled using javac. These
 * are not included in the build path of "lrn" project so as to not have those
 * default loaded by the parent class loader.
 * 
 */
public class TestClassLoader {

    public static boolean useParent = true;

    private static void loadIt(String className) {
	SimpleClassLoader cl = new SimpleClassLoader();
	try {
	    Object obj = (cl.loadClass(className, false)).newInstance();
	    System.out.println(obj.getClass() + " loaded using "
		    + obj.getClass().getClassLoader() + ".");
	} catch (Exception e) {
	    System.out.println("Caught exception : " + e);
	}
    }

    public static void main(String[] args) {

	String name;

	// Ordinary instantiation. No class loader business here.
	System.out.println("-----Testing custom class loader-----");
	String s = new String("bla");

	// ---------------- "useParent = true" cases ------------------------
	useParent = true;

	// A system class (e.g. java.lang.*) will always be available with
	// Parent class loader.
	name = "java.lang.Object";
	System.out.println("-----Testing custom class loader-----");
	loadIt(name);

	// Application specific class will not be available with Parent class
	// loader and hence custom loader will get invoked. Note
	// that for any "new" or "static access" calls within a custom loaded
	// class will be routed via the custom loader. In such
	// a case also, all system classes will get loaded by the Parent loader.
	name = "pkg1.TestClass";
	System.out.println("-----Testing custom class loader-----");
	loadIt(name);

	// Application specific class so should get loaded by custom loader.
	// However, the byte code is invalid and hencw will get BadFormatError
	// Exception.
	name = "pkg1.BadFormat";
	useParent = true;
	System.out.println("-----Testing custom class loader-----");
	loadIt(name);

	// ---------------- "useParent = false" cases ------------------------
	useParent = false;

	// Can't custom load system classes, should get SecurityException.
	name = "java.lang.Object";
	System.out.println("-----Testing custom class loader-----");
	loadIt(name);

	// Can custom load application class but any system class that gets
	// loaded as part of it will get SecurityException. Since it can't load
	// system class, it will get NoClassDefErrorFound exception and will
	// exit.
	name = "pkg1.TestClass";
	System.out.println("-----Testing custom class loader-----");
	loadIt(name);
    }

}

class SimpleClassLoader extends ClassLoader {
    private static final int BUFFER_SIZE = 8192;
    private static final String BASE_DIR = "/Users/ajayc/Work/bak/tch/code/lrn/src/aj/nobuild/";

    @Override
    protected synchronized Class loadClass(String className, boolean resolve)
	    throws ClassNotFoundException {
	System.out.println("Class: " + className + ", resolve: " + resolve);

	// 1. Is it already loaded?
	Class cls = findLoadedClass(className);
	if (cls != null) {
	    System.out.println("Already loaded.");
	    return cls;
	}

	// 2. Is it available with the parent class loader
	// The loadClass methos signature can not be changed. Hence this kludge
	// of using a public static
	// boolean from the outer class.
	if (TestClassLoader.useParent) {
	    try {
		cls = super.loadClass(className, resolve);
		if (cls != null) {
		    System.out.println("Parent class loader has it.");
		    return cls;
		}
	    } catch (ClassNotFoundException e) {
		// Ignore, will load it using this custom loader.
	    }
	}

	System.out.println("Doing custom load.");

	// 3a. Construct file path using BASE_DIR
	String clsFile = BASE_DIR + className.replace('.', '/') + ".class";
	System.out.println(clsFile);

	// 3b. Read the class file into byte array
	byte[] classBytes = null;
	try {
	    // InputStream in = getResourceAsStream(clsFile);
	    InputStream in = new FileInputStream(clsFile);

	    byte[] buffer = new byte[BUFFER_SIZE];
	    ByteArrayOutputStream out = new ByteArrayOutputStream();
	    int n = -1;
	    while ((n = in.read(buffer, 0, BUFFER_SIZE)) != -1) {
		out.write(buffer, 0, n);
	    }
	    classBytes = out.toByteArray();
	} catch (IOException e) {
	    System.out.println("ERROR loading class file: " + e);
	}

	if (classBytes == null) {
	    throw new ClassNotFoundException("Cannot load class: " + className);
	}

	// 3c. Turn the byte array into a Class
	try {
	    cls = defineClass(className, classBytes, 0, classBytes.length);
	    if (resolve) {
		resolveClass(cls);
	    }
	} catch (SecurityException e) {
	    // loading core java classes such as java.lang.String
	    // is prohibited, throws java.lang.SecurityException.
	    System.out.println(e);
	    throw new ClassNotFoundException("Cannot load class: " + className);
	} catch (ClassFormatError e) {
	    // Will be thrown if its not valid byte code.
	    System.out.println(e);
	    throw new ClassNotFoundException("Cannot load class: " + className);

	}

	return cls;
    }
}
