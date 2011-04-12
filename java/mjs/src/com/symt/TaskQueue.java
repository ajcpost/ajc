package com.symt;

import java.util.Iterator;
import java.util.concurrent.ArrayBlockingQueue;

// Caveat- Hard-coded the queue size to 1000.
// Caveat- No cleanup (removal of tasks) implemented.
public class TaskQueue {
	private ArrayBlockingQueue<Task> m_tasks;
	private Object m_sync = new Object();
	private long m_numNewTasks = 0;

	public TaskQueue() {
		m_tasks = new ArrayBlockingQueue<Task>(1000);
		m_numNewTasks = 0;
	}

	public void notifyConsumer() {
		synchronized (m_sync) {
			m_sync.notify();
		}
	}

	public void append(Task t) {
		try {
			m_tasks.put(t);
		} catch (InterruptedException ex) {
			return;
		}
		incrementNumNewTasks();
		notifyConsumer();
	}

	protected Task getNextNew() throws InterruptedException {
		waitForNewTask();
		Task nextNew = null;
		synchronized (this) {
			Iterator it = m_tasks.iterator();
			while (it.hasNext()) {
				Task task = (Task) it.next();
				if (task.isNew()) {
					nextNew = task;
					nextNew.setTaken();
					decrementNumNewTask();
					break;
				}
			}
			return nextNew;
		}
	}

	private void waitForNewTask() throws InterruptedException {
		synchronized (m_sync) {
			while (true) {
				if (numOfNewTasks() > 0) {
					break;
				} else {
					m_sync.wait();
				}
			}
		}
	}

	private synchronized long numOfNewTasks() {
		return m_numNewTasks;
	}

	private synchronized void incrementNumNewTasks() {
		++m_numNewTasks;
	}

	private synchronized void decrementNumNewTask() {
		--m_numNewTasks;
	}
}