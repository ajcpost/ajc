package aj.io.fileviewer;

import java.io.*;

public class DumpFile {

    public static void dump(File file, Writer out, DisplayOptions options)
	    throws IOException {

	Reader in = StreamFactory.getReaderInstance(options, file);

	/*for (int c = in.read(); c != -1; c = in.read()) {
	    out.write(c);
	}*/
	    while (true) {
		int data = in.read();
		if (data == -1)
		    break;
		out.write(data);
	    }
	    in.close();
	    out.close();

    }
}
