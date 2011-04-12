package aj.io.stream;

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
	// copyUsingByte(filename);
	copyUsingChar(filename);
    }

    // Uses byte access and hence will be able to read and display the file
    // contents correctly.
    private void copyUsingByte(String filename) throws IOException {
	long start = System.currentTimeMillis();
	FileInputStream fin = new FileInputStream(filename);
	FileOutputStream fout = new FileOutputStream(filename + ".copy");
	DataInputStream dis = new DataInputStream(fin);
	DataOutputStream dos = new DataOutputStream(fout);
	try {
	    while (true) {
		int receivedByte = dis.readByte();
		if (receivedByte == -1)
		    break;
		// dos.writeByte(receivedByte);
		System.out.write(receivedByte);
	    }
	} catch (EOFException e) {
	    // Do nothing
	} finally {
	    if (dis != null)
		closeIgnoringException(dis);
	    if (dos != null)
		closeIgnoringException(dos);
	    if (fin != null)
		closeIgnoringException(fin);
	    if (fout != null)
		closeIgnoringException(fout);
	}

	long end = System.currentTimeMillis();
	System.out.println("Data stream byte copy  took:" + (end - start));
    }

    // Uses char access and hence will _not_ be able to read and display the
    // file contents correctly.
    private void copyUsingChar(String filename) throws IOException {
	long start = System.currentTimeMillis();
	FileInputStream fin = new FileInputStream(filename);
	FileOutputStream fout = new FileOutputStream(filename + ".copy");
	DataInputStream dis = new DataInputStream(fin);
	DataOutputStream dos = new DataOutputStream(fout);
	try {
	    while (true) {
		int receivedByte = dis.readChar();
		if (receivedByte == -1)
		    break;
		// dos.writeChar(receivedByte);
		System.out.write(receivedByte);
	    }
	} catch (EOFException e) {
	    // Do nothing
	} finally {
	    if (dis != null)
		closeIgnoringException(dis);
	    if (dos != null)
		closeIgnoringException(dos);
	    if (fin != null)
		closeIgnoringException(fin);
	    if (fout != null)
		closeIgnoringException(fout);
	}

	long end = System.currentTimeMillis();
	System.out.println("Data stream char copy  took:" + (end - start));
    }

    private static void closeIgnoringException(Closeable c) {
	try {
	    c.close();
	} catch (IOException e) {
	    // Do nothing
	}
    }

}
