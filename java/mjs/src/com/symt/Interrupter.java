package com.symt;

import java.util.TimerTask;

public final class Interrupter extends TimerTask {
	private Thread m_consumer = null;
	private Interrupter() {
	}
	public Interrupter(Thread consumer) {
		m_consumer = consumer;
	}

	public void run() {
		m_consumer.interrupt();
	}
}
