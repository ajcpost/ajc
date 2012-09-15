package aj.io.socket;

import java.io.*;
import java.util.concurrent.*;

public class ClientMain {
    private final static int MAX_CLIENTS = 100;
    private final static int MAX_ITERATIONS = 100;
    private final static int MAX_SLEEPTIME_MS = 10 * 1000;
    private final static String SERVER_ADDRESS = "127.0.0.1";
    private final static int SERVER_PORT = 5555;

    private static int configuredClients;
    private static int configuredIterations;
    private static int configuredSleepTime;

    private static ExecutorService threadPool;

    public static void main(String[] args) {

	try {
	    validateArgs(args);
	    initializeThreadPool();
	    talkToServer();
	} catch (Exception e) {
	    System.out.println("Error in client:");
	    e.printStackTrace();
	}
	finally {
	    try {
		cleanup ();
	    } catch (Exception e) {
		// Nothing much to do
	    }   
	}
    }

    private static void validateArgs(String[] args) {
	if (args.length != 3) {
	    System.out
		    .println("Usage: <ClientMain> <num clients(capped at 100)> <num iterations(capped at 100)> <sleep time in ms(capped at 10000)>");
	    System.exit(-1);
	}

	configuredClients = Math.min(MAX_CLIENTS, Integer.valueOf(args[0]));
	configuredIterations = Math.min(MAX_ITERATIONS, Integer
		.valueOf(args[1]));
	configuredSleepTime = Math.min(MAX_SLEEPTIME_MS, Integer
		.valueOf(args[2]));

	System.out.println("Client configured with " + configuredClients
		+ " threads, each looping for " + configuredIterations
		+ " with sleep time of " + configuredSleepTime);
    }

    private static void initializeThreadPool() {
	threadPool = Executors.newFixedThreadPool(configuredClients);
	System.out.println("Client pool initialized with "
		+ threadPool.toString());
    }

    private static void talkToServer() throws IOException, InterruptedException {
	System.out.println("ClientMain spawning threads to talk with the servers...");

	for (int i = 0; i < configuredClients; i++) {
	    threadPool.execute(new ClientWorker(SERVER_ADDRESS, SERVER_PORT, configuredIterations,
		    configuredSleepTime));
	}
	long timeToWait = 10000L * configuredIterations * configuredSleepTime;
	System.out
		.println("ClientMain awaiting " + timeToWait + " ms for termination of worker threads...");
	threadPool.awaitTermination(timeToWait, TimeUnit.MILLISECONDS);
	threadPool.shutdown();
	System.out.println("All client worker threads done.");
    }

    private static void cleanup() throws IOException {
	if (threadPool != null) {
	    threadPool.shutdownNow();
	}
    }

}
