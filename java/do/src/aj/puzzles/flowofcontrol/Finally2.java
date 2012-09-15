package aj.puzzles.flowofcontrol;

import java.io.*;

/**
 * "Exceptions thrown in finally must be caught"
 * 
 * The in.close can throw IOException which will result in out stream not
 * getting closed.
 * 
 */

// Will the program close all open streams?
public class Finally2 {

    static void copy(String src, String dest) throws IOException {
	InputStream in = null;
	OutputStream out = null;
	try {
	    in = new FileInputStream(src);
	    out = new FileOutputStream(dest);
	    byte[] buf = new byte[1024];
	    int n;
	    while ((n = in.read(buf)) >= 0)
		out.write(buf, 0, n);
	} finally {
	    if (in != null)
		in.close();
	    if (out != null)
		out.close();
	}
    }

    public static void main(String[] args) {
	try {
	    copy("testfile1", "testfile2");
	} catch (IOException e) {
	    e.printStackTrace();
	}
    }
}