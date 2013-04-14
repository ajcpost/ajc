package aj.io.readerwriter;

import java.io.*;

/**
 * Uses Data*Stream and hence dependent on file encoding if a non-byte access is
 * performed.
 * 
 */
public class FileCopy2 {

    public static void main(String[] args) throws IOException {
	if (args.length != 1) {
	    System.err.println("Usage: java FileCopy2 filename");
	    return;
	}
	FileCopy2 fc = new FileCopy2();
	fc.copyFile(args[0]);
    }

    public void copyFile(String filename) throws IOException {
	copyUsingChar(filename);
    }


    // Uses char access and hence will _not_ be able to read and display the
    // file contents correctly.
    private void copyUsingChar(String filename) throws IOException {
	long start = System.currentTimeMillis();
	FileReader fin = new FileReader(filename);
	FileWriter fout = new FileWriter(filename + ".copy");
	System.out.println();
	System.out.println();
	System.out.println("Input file encoding:" + fin.getEncoding());
	System.in.read();
	System.out.println();
	System.out.println();
	try {
	    while (true) {
		int receivedByte = fin.read();
		if (receivedByte == -1)
		    break;
		// fout.writeChar(receivedByte);
		System.out.write(receivedByte);
	    }
	} catch (EOFException e) {
	    // Do nothing
	} finally {
	    if (fin != null)
		closeIgnoringException(fin);
	    if (fout != null)
		closeIgnoringException(fout);
	}

	long end = System.currentTimeMillis();
	System.out.println("File read char copy  took:" + (end - start));
    }

    private static void closeIgnoringException(Closeable c) {
	try {
	    c.close();
	} catch (IOException e) {
	    // Do nothing
	}
    }

}
