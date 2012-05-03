package aj.io.stream;

import java.io.*;

// Extends FilterStream to create a Stream that displays only printable chars.
public class FilterStreamExample {

    public static void main(String[] args) {
	if (args.length < 1) {
	    System.out.println("Usage: java <path to some class file>");
	    return;
	}
	
	InputStream in = null;
	OutputStream out = null;
	try {
	    in = new FileInputStream(args[0]);
	    if (args.length >= 2) {
		out = new FileOutputStream(args[1]);
	    } else {
		out = System.out;
	    }

	    // Output stream is chained to the custom filter stream
	    MyOutputStream pout = new MyOutputStream(out);
	    for (int c = in.read(); c != -1; c = in.read()) {
		pout.write(c);
	    }
	} catch (Exception e) {
	    System.out.println(e);
	} finally {
	    if (in != null) closeIgnoringException (in);
	    if (out != null) closeIgnoringException (out);
	}
    }

    private static void closeIgnoringException(Closeable c) {
	try {
	    c.close();
	} catch (IOException e) {
	    // Do nothing
	}
    }

}

class MyOutputStream extends FilterOutputStream {
    public MyOutputStream(OutputStream out) {
	super(out);
    }

    @Override
    public void write(int b) throws IOException {
	// carriage return, linefeed, and tab
	if (b == '\n' || b == '\r' || b == '\t')
	    out.write(b);
	// non-printing characters
	else if (b < 32 || b > 126)
	    out.write('?');
	// printing, ASCII characters
	else
	    out.write(b);
    }

    @Override
    public void write(byte[] data, int offset, int length) throws IOException {
	for (int i = offset; i < offset + length; i++) {
	    this.write(data[i]);
	}
    }
}
