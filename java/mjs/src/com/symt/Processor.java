package com.symt;

public final class Processor {

	public Processor() {
	}

	public void process(Object data, int cancelTime, boolean testCancel)
			throws InterruptedException {

		if (testCancel) {
			// Sleep long enough to have the Timer thread come and cancel the
			// op.
			Thread.sleep(cancelTime * 2);
		}

		Trace.dump("Processing data - " + data.toString());
		// Some processing for input 'data'
	}
}