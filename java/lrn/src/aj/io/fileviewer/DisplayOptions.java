package aj.io.fileviewer;

import java.io.*;
import aj.io.fileviewer.filterstreams.*;

enum DataType {
    ASC("java.io.DataInputStream", "java.io.DataInputStream"), 
    DEC("aj.io.fileviewer.filterstreams.DecimalInputFilterStream", "aj.io.fileviewer.filterstreams.DecimalInputFilterStream"),
    HEX("aj.io.fileviewer.filterstreams.HexInputFilterStream","aj.io.fileviewer.filterstreams.HexInputFilterStream");  /*SHORT, INT, LONG, FLOAT, DOUBLE; */

    private String bigEndianClassName;
    private String littleEndianClassName;

    
    DataType(String big, String little) {
	this.bigEndianClassName = big;
	this.littleEndianClassName = little;
    }

    public FilterInputStream getFilterStream(boolean bigEndian, InputStream in) {

	FilterInputStream fin = null;
	try {
	    if (bigEndian) {
		Class c = Class.forName(bigEndianClassName);
		fin = ((FilterInputStream) c.getConstructor(InputStream.class)
			.newInstance(in));
	    }
	    Class c = Class.forName(littleEndianClassName);
	    fin = ((FilterInputStream) c.getConstructor(InputStream.class)
		    .newInstance(in));
	} catch (Exception e) {
	    System.out.println(e.getMessage());
	}
	return fin;
    }
}

public final class DisplayOptions {
    private final DataType dataType;
    private final boolean bigEndian;
    private final boolean deflated;
    private final boolean gzipped;
    private final String encoding;
    private final String password;

    public DisplayOptions(DataType dataType, boolean bigEndian,
	    boolean deflated, boolean gzipped, String encoding, String password) {
	this.dataType = dataType;
	this.bigEndian = bigEndian;
	this.deflated = deflated;
	this.gzipped = gzipped;
	this.encoding = encoding;
	this.password = password;
    }

    public DataType getDataType() {
	return dataType;
    }

    public boolean isBigEndian() {
	return bigEndian;
    }

    public boolean isDeflated() {
	return deflated;
    }

    public boolean isGzipped() {
	return gzipped;
    }

    public String getEncoding() {
	return encoding;
    }

    public String getPassword() {
	return password;
    }
}