package aj.io.stream;

import java.io.*;

public class DisplayAsciiChart {

    // Writes byte by byte.
    private static void slower() {
	long start = System.currentTimeMillis();

	for (int i = 32; i < 127; i++) {
	    System.out.write(i);
	    // break line after every eight characters.
	    if (i % 8 == 7)
		System.out.write('\n');
	    else
		System.out.write('\t');
	}
	System.out.write('\n');
	long end = System.currentTimeMillis();
	System.out.println("Slower took:" + (end - start));

    }

    // Constructs a byte array and writes in single call.
    private static void faster() {
	long start = System.currentTimeMillis();

	byte[] b = new byte[(127 - 31) * 2];
	int index = 0;
	for (int i = 32; i < 127; i++) {
	    b[index++] = (byte) i;
	    // Break line after every eight characters.
	    if (i % 8 == 7)
		b[index++] = (byte) '\n';
	    else
		b[index++] = (byte) '\t';
	}
	b[index++] = (byte) '\n';
	try {
	    System.out.write(b);
	} catch (IOException ex) {
	    System.err.println(ex);
	}
	long end = System.currentTimeMillis();
	System.out.println("Faster took:" + (end - start));

    }

    public static void main(String[] args) {
	slower();
	faster();
    }
}
