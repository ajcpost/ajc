package aj.io.socket;

import java.net.*;
import java.io.*;

public class ServerWorker implements Runnable {

    private final Socket clientSocket;
    private final int configuredIterations;
    private final int configuredSleepTime;
    private String serverName;

    public ServerWorker(Socket socket, int configuredIterations, int configuredSleepTime) {
	this.clientSocket = socket;
	this.configuredIterations = configuredIterations;
	this.configuredSleepTime = configuredSleepTime;
    }

    public void run() {

	serverName = "Server-" + Thread.currentThread().getId();

	InputStream input = null;
	OutputStream output = null;
	BufferedReader inputBuf = null;
	BufferedWriter outputBuf = null;

	try {
	    input = clientSocket.getInputStream();
	    output = clientSocket.getOutputStream();
	    inputBuf = new BufferedReader(new InputStreamReader(input));
	    outputBuf = new BufferedWriter(new OutputStreamWriter(output));
	    System.out.println(serverName + " all streams opened.");
	    System.out.println(serverName + " iterating...");

	    String iterationId;
	    for (int i = 0; i < configuredIterations; i++) {
		iterationId = serverName + " loop is " + i;

		// Read client request
		String clientInput = inputBuf.readLine();
		System.out.println(iterationId + " received: " + clientInput);

		// Sleep
		Thread.sleep(configuredSleepTime);

		// Write server response
		outputBuf.write(iterationId);
		outputBuf.newLine();
		outputBuf.flush();
	    }
	} catch (Exception e) {
	    // report exception somewhere.
	    e.printStackTrace();
	}
	finally {
	    closeIgnoringException(inputBuf);
	    closeIgnoringException(outputBuf);
	    closeIgnoringException(inputBuf);
	    closeIgnoringException(outputBuf);
	    System.out.println(serverName + " done.");
	}
    }
    
    private static void closeIgnoringException(Closeable c) {
	if (c != null) {
	    try {
		c.close();
	    } catch (IOException ex) {
		// Nothing we can do if close fails
	    }
	}
    }
}
