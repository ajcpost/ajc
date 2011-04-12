package aj.io.fileviewer.filterstreams;

import java.io.*;

public class HexInputFilterStream extends BaseInputFilterStream {
    private int numRead = 0;
    private int breakAfter = 24;
    private int ratio = 3; // Number of bytes of output per byte of input.

    public HexInputFilterStream(InputStream in) {
	super(in);
    }

    @Override
    protected void fill() throws IOException {
	buf = new int[ratio];
	int datum = in.read();
	this.numRead++;
	if (datum == -1) {
	    // Let read( ) handle end of stream.
	    throw new EOFException();
	}
	String hex = Integer.toHexString(datum);
	if (datum < 16) { // Add a leading zero.
	    hex = '0' + hex;
	}
	for (int i = 0; i < hex.length(); i++) {
	    buf[i] = hex.charAt(i);
	}
	if (numRead < breakAfter) {
	    buf[buf.length - 1] = ' ';
	} else {
	    buf[buf.length - 1] = '\n';
	    numRead = 0;
	}
    }

    @Override
    public int available() throws IOException {
	return (buf.length - index) + ratio * in.available();
    }
}
