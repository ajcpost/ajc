package aj.io.socket;

import java.net.*;
import java.io.*;

public class ClientWorker implements Runnable {

    private Socket mySocket;
    private final int configuredIterations;
    private final int configuredSleepTime;
    private final String serverAddress;
    private final int serverPort;

    private String clientName;

    public ClientWorker(String serverAddress, int serverPort,
	    int configuredIterations, int configuredSleepTime) {
	this.serverAddress = serverAddress;
	this.serverPort = serverPort;
	this.configuredIterations = configuredIterations;
	this.configuredSleepTime = configuredSleepTime;
    }

    public void run() {

	this.clientName = "Client-" + Thread.currentThread().getId();

	InputStream input = null;
	OutputStream output = null;
	BufferedReader inputBuf = null;
	BufferedWriter outputBuf = null;
	try {
	    InetAddress addr = InetAddress.getByName(serverAddress);
	    mySocket = new Socket(addr, serverPort);
	    System.out.println(clientName + " connected to the server.");

	    input = mySocket.getInputStream();
	    output = mySocket.getOutputStream();
	    inputBuf = new BufferedReader(new InputStreamReader(input));
	    outputBuf = new BufferedWriter(new OutputStreamWriter(output));
	    System.out.println(clientName + " opened in/out streams.");

	    System.out.println(clientName + " iterating...");

	    String iterationId;
	    for (int i = 0; i < configuredIterations; i++) {
		// Send req to server
		iterationId = clientName + " loop is " + i;
		outputBuf.write(iterationId);
		outputBuf.newLine();
		outputBuf.flush();
		System.out.println(iterationId);

		// Sleep
		Thread.sleep(configuredSleepTime);

		// Read server response
		String serverInput = inputBuf.readLine();
		System.out.println(iterationId + " received: " + serverInput);
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
	    System.out.println(clientName + " done.");
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
