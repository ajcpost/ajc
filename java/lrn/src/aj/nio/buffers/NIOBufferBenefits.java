package aj.nio.buffers;

import java.io.*;

public class NIOBufferBenefits {

    private static float[] values = new float[100];
 
    public static void main(String[] args) {
	
	for (int i=0;i<values.length;i++) {
	    values[i] = (float) 10.10;
	}
	
	try {
	ioInefficientCopy ();
	ioEfficientCopy ();
	//nioBufferCopy ();
	}
	catch (Exception e) {
	    e.printStackTrace();
	}
    }

    
    private static void ioInefficientCopy () throws IOException
    {
	long start = System.currentTimeMillis();
	PrintStream out = new PrintStream (System.out);
	for (int i=0; i<values.length; i++) {
	    out.print(values[i]);
	}
	long end = System.currentTimeMillis();
	System.out.println();
	System.out.println("ioInefficientCopy: " + (end-start));
	System.out.println();
	out.flush();
    }

    private static void ioEfficientCopy () throws IOException
    {
	long start = System.currentTimeMillis();
	ObjectOutputStream out = new ObjectOutputStream (System.out);
	out.writeObject(values);
	long end = System.currentTimeMillis();
	System.out.println();
	System.out.println("ioEfficientCopy: " + (end-start));
	System.out.println();
	out.flush();
    }

}
