package aj.io.fileviewer;

import java.io.*;
import java.security.GeneralSecurityException;
import java.util.zip.GZIPInputStream;
import java.util.zip.InflaterInputStream;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.DESKeySpec;
//import javax.swing.ProgressMonitorInputStream;
//import aj.io.fileviewer.filterstreams.*;

public class StreamFactory {

    public static Reader getReaderInstance(DisplayOptions options, File file)
	    throws IOException {

	InputStream in = new FileInputStream(file);
	in = new BufferedInputStream(in);
	// in = new ProgressMonitorInputStream(this, "Reading...", in);

	if (options.getPassword() != null && !options.getPassword().equals("")) {
	    // Create a key.
	    try {
		byte[] desKeyData = options.getPassword().getBytes();
		DESKeySpec desKeySpec = new DESKeySpec(desKeyData);
		SecretKeyFactory keyFactory = SecretKeyFactory
			.getInstance("DES");
		SecretKey desKey = keyFactory.generateSecret(desKeySpec);
		Cipher des = Cipher.getInstance("DES/ECB/PKCS5Padding");
		des.init(Cipher.DECRYPT_MODE, desKey);
		in = new CipherInputStream(in, des);
	    } catch (GeneralSecurityException ex) {
		throw new IOException(ex.getMessage());
	    }
	}
	if (options.isDeflated()) {
	    in = new InflaterInputStream(in);
	} else if (options.isGzipped()) {
	    in = new GZIPInputStream(in);
	}

	in = options.getDataType().getFilterStream(options.isBigEndian(), in);
	String encoding = options.getEncoding();
	if (encoding == null || encoding.equals("")) {
	    encoding = "US-ASCII";
	}
	InputStreamReader isr = new InputStreamReader(in, encoding);

	return isr;
    }
}
