package aj.io.socket;

import java.net.*;
import java.io.*;
import java.util.concurrent.*;

public final class ServerMain {

    private final static int MAX_SERVERS = 100;
    private final static int MAX_ITERATIONS = 100;
    private final static int MAX_SLEEPTIME_MS = 10 * 1000;
    private final static int SERVER_PORT = 5555;

    private static int configuredServers;
    private static int configuredterations;
    private static int configuredleepTime;

    private static ServerSocket socket;
    private static ExecutorService threadPool;

    public static void main(String[] args) {

	try {
	    validateArgs(args);
	    initializeServerSocket();
	    initializeThreadPool();
	    waitForClients();
	} catch (Exception e) {
	    System.out.println("Error in server:");
	    e.printStackTrace();
	} finally {
	    try {
		cleanup();
	    } catch (Exception e) {
		// Nothing much to do
	    }

	}
    }

    private static void validateArgs(String[] args) {
	if (args.length != 3) {
	    System.out
		    .println("Usage: <ServerMain> <num servers(capped at 10)> <num iterations(capped at 100)> <sleep time in ms(capped at 10000)>");
	    throw new IllegalArgumentException("Incorrect arguments");
	}

	configuredServers = Math.min(MAX_SERVERS, Integer.valueOf(args[0]));
	configuredterations = Math
		.min(MAX_ITERATIONS, Integer.valueOf(args[1]));
	configuredleepTime = Math.min(MAX_SLEEPTIME_MS, Integer
		.valueOf(args[2]));

	System.out.println("Server configured with " + configuredServers
		+ " threads, each looping for " + configuredterations
		+ " with a sleep time of " + configuredleepTime + "ms.");
    }

    private static void initializeServerSocket() throws IOException {
	socket = new ServerSocket(SERVER_PORT);
	System.out.println("Server socket initialized with "
		+ socket.toString());
    }

    private static void initializeThreadPool() {
	threadPool = Executors.newFixedThreadPool(configuredServers);
	System.out.println("Server pool initialized with "
		+ threadPool.toString());
    }

    private static void waitForClients() throws IOException {
	System.out.println("Server waiting for clients to connect...");
	while (true) {
	    threadPool.execute(new ServerWorker(socket.accept(),
		    configuredterations, configuredleepTime));

	}
    }

    private static void cleanup() throws IOException {
	if (socket != null) {
	    socket.close();
	}
	if (threadPool != null) {
	    threadPool.shutdownNow();
	}
    }

}
