package com.symt;

import java.util.Timer;
import java.lang.ClassLoader;

public final class Consumer extends Thread {
	private static Timer s_timer = null;
	private TaskQueue m_taskQueue = null;
	private String m_classToLoad = null;
	private int m_cancelTime = 5 * 1000;
	private boolean m_testCancel = false;

	private Consumer() {
	}

	public Consumer(String consumerName, TaskQueue tQueue, String classToLoad,
			int cancelTime, boolean testCancel) throws IllegalArgumentException {

		if (consumerName == null || tQueue == null || classToLoad == null) {
			throw new IllegalArgumentException("Null input");
		}
		if (s_timer == null) {
			s_timer = new Timer();
		}

		this.setName(consumerName);

		m_taskQueue = tQueue;
		m_classToLoad = classToLoad;
		m_cancelTime = cancelTime * 1000; // msecs
		m_testCancel = testCancel;
	}

	// Always running. No shutdown mechanisms implemented.
	public void run() {
		Task workTask = null;
		while (true) {
			try {
				workTask = m_taskQueue.getNextNew();
				if (workTask == null) {
					continue;
				}
				s_timer.schedule(new Interrupter(this), m_cancelTime);

				// Instantiate the class to process the file
				ClassLoader cl = ClassLoader.getSystemClassLoader();
				Object myObj = cl.loadClass(m_classToLoad).newInstance();
				if (myObj instanceof Processor) {
					((Processor) myObj).process(workTask.getData(),
							m_cancelTime, m_testCancel);
				}

				// No cancellations. Work complete.
				workTask.setCompleted();
				Trace.dump(workTask.getData() + " completed by "
						+ this.getName());
			} catch (InterruptedException ie) {
				if (workTask != null && !workTask.isCompleted()) {
					workTask.setInterrupted();
					Trace.dump(workTask.getData() + " interrupted in "
							+ this.getName());
				}
			} catch (Exception ex) {
				ex.printStackTrace();
			} catch (Throwable th) {
				th.printStackTrace();
			}
		}
	}
}