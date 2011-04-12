package com.symt;

import java.io.File;

// Caveat-- Entire package code is at sample level and not a real 
// production ready code. 
public final class Producer {

	private static Producer m_producer = null;
	private TaskQueue m_taskQueue = null;

	// Force singleton
	private Producer() {
	}

	public static Producer getInstance(TaskQueue tQueue)
			throws IllegalArgumentException {
		if (tQueue == null) {
			throw new IllegalArgumentException("Null input");
		}
		if (m_producer == null) {
			m_producer = new Producer();
			m_producer.m_taskQueue = tQueue;
		}
		return m_producer;
	}

	// Read the directory and add all files to the task queue.
	public void produce(String dirPath) {
		if (dirPath == null) {
			throw new IllegalArgumentException("Null input");
		}
		File f = new File(dirPath);
		if (!f.isDirectory()) {
			Trace.dump(dirPath + " is not a directory");
			usage();
		}
		String[] listFiles = f.list();
		for (int i = 0; i < listFiles.length; i++) {
			Trace.dump("Adding task for file " + listFiles[i]);
			Task t = new Task(listFiles[i]);
			m_taskQueue.append(t);
		}
	}

	private static void usage() {
		Trace.dump("App <dirPath:String> <no. of consumer threads:int> "
				+ "<class to load: String> <cancel water mark: int>"
				+ "<test cancel:true/false");
		System.exit(1);
	}

	// Bare minimal command line parsing. Assuming that the user
	// will pass all the required arguments in the expected order
	// and format. This will require much modifications for a
	// production quality code. The arguments are:
	// - The directory to read files from (String)
	// - No. of threads for processing the files (int)
	// - Name of the class to load for 'process' function (symt.processor)
	// - How much time to wait before cancelling the task (seconds-int)
	// - Used for testing the cancel functionality(true/false)
	public static void main(String[] args) {

		try {
			if (args.length != 5) {
				usage();
			}
			String dirPath = args[0];
			Integer numConsumers = new Integer(args[1]);
			String classToLoad = args[2];
			Integer cancelTime = new Integer(args[3]);
			Boolean testCancel = new Boolean(args[4]);

			// Create the queue for the tasks (one per file) and pass 
			// it on to the producer and consumers.
			TaskQueue tQueue = new TaskQueue();
			Producer prdc = Producer.getInstance(tQueue);
			for (int i = 0; i < numConsumers.intValue(); i++) {
				String consumerName = "Consumer_" + i;
				Consumer c = new Consumer(consumerName, tQueue, classToLoad,
						cancelTime, testCancel);
				c.start();
			}

			// Produce the tasks and let consumer threads take care of
			// processing.
			prdc.produce(dirPath);
		} catch (Throwable th) {
			th.printStackTrace();
		}
	}
}