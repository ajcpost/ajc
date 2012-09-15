package aj.io.fileviewer.filterstreams;

import java.io.*;

public abstract class DataInputFilterStream extends BaseInputFilterStream {
    // The use of DataInputStream here is a little forced.
    // It would be more natural (though more complicated)
    // to read the bytes and manually convert them to an int.
    protected DataInputStream din;

    public DataInputFilterStream(DataInputStream din) {
	super(din);
	this.din = din;
    }

    @Override
    public int available() throws IOException {
	return (buf.length - index) + in.available();
    }
}
