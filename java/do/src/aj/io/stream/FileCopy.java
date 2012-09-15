package aj.io.stream;

import java.io.*;

/**
 * Uses Streams and hence not dependent on file encoding. Will read byte(s) and
 * write byte(s)
 * 
 */
public class FileCopy {

    public static void main(String[] args) throws IOException {
	if (args.length != 1) {
	    System.err.println("Usage: java FileCopy filename");
	    return;
	}
	FileCopy fc = new FileCopy();
	fc.copyFile(args[0]);
    }

    public void copyFile(String filename) throws IOException {
	copyByteArray(filename);
	copyBuffered(filename);
	copyByte(filename);
    }

    // Loop through each individual byte. Every byte read or written corresponds
    // to single IO system call. Every while iteration is two system calls and
    // hence is slow.
    // fin/fout will internally use their own data copy, separate from receivedByte
    private void copyByte(String filename) throws IOException {
	long start = System.currentTimeMillis();

	FileInputStream fin = new FileInputStream(filename);
	FileOutputStream fout = new FileOutputStream(filename + ".copy");

	try {
	    while (true) {
		int receivedByte = fin.read();
		if (receivedByte == -1)
		    break;
		fout.write(receivedByte);
		//System.out.write(receivedByte);
	    }
	} finally {
	    fin.close();
	    fout.close();
	}

	long end = System.currentTimeMillis();
	System.out.println("Byte copy took:" + (end - start));
    }

    // Loop through reading chunks of bytes. Every chunk read or written
    // corresponds to an IO system call.
    // fin/fout will internally use their own data copy, separate from dataByte[]
    private void copyByteArray(String filename) throws IOException {
	long start = System.currentTimeMillis();
	FileInputStream fin = new FileInputStream(filename);
	FileOutputStream fout = new FileOutputStream(filename + ".copy");

	try {
	    byte dataBytes[] = new byte[1024];
	    while (true) {
		int dataLen = fin.read(dataBytes);
		if (dataLen == -1)
		    break;
		fout.write(dataBytes, 0, dataLen);
	    }
	} finally {
	    fin.close();
	    fout.close();
	}

	long end = System.currentTimeMillis();
	System.out.println("Byte array copy took:" + (end - start));
    }

    // Loop through reading via buffered stream. Every chunk read or written
    // corresponds to an IO system call.
    // bis/bos will internally use their own data copy, separate from receivedByte
    private void copyBuffered(String filename) throws IOException {
	long start = System.currentTimeMillis();
	FileInputStream fin = new FileInputStream(filename);
	FileOutputStream fout = new FileOutputStream(filename + ".copy");
	BufferedInputStream bis = new BufferedInputStream(fin);
	BufferedOutputStream bos = new BufferedOutputStream(fout);
	try {
	    while (true) {
		int receivedByte = bis.read();
		if (receivedByte == -1)
		    break;
		bos.write(receivedByte);
	    }
	} finally {
	    if (bis != null)
		closeIgnoringException(bis);
	    if (bos != null)
		closeIgnoringException(bos);
	    if (fin != null)
		closeIgnoringException(fin);
	    if (fout != null)
		closeIgnoringException(fout);
	}

	long end = System.currentTimeMillis();
	System.out.println("Buffered copy took:" + (end - start));
    }
    
    private static void closeIgnoringException (Closeable c) {
	try {
	    c.close();
	}
	catch (IOException e) {
	    // Do nothing
	}
    }

}
