package aj.locks.impl;

import aj.locks.RWLock;
import java.util.*;

/**
 * Partial reentrant implementation
 * 
 * (Read lock)
 * - Grant if no thread has acquired write lock or is requesting one
 * - Don't block if the thread already has read lock
 * (Write lock) 
 * - Grant if no thread has acquired write lock or read lock
 * - Don't block if the thread already has write lock
 * - Give priority to write lock if a read & write request is made simultaneously
 * 
 * 
 */
public class RWLockEnt implements RWLock {

	private int numReaders = 0;
	private int numWriters = 0;
	private boolean writeLockInprogress = false;
	private Map<Thread, Integer> readers = new HashMap<Thread, Integer>();
	private Thread writer = null;

	public synchronized void acquireRead() throws InterruptedException {
		while (!canRead()) {
			wait();
		}
		numReaders++;
		addToMap(readers);
	}

	public synchronized void releaseRead() {
		numReaders--;
		notifyAll();
		removeFromMap(readers);
	}

	public synchronized void acquireWrite() throws InterruptedException {

		writeLockInprogress = true;
		while (!canWrite()) {
			wait();
		}
		numWriters++;
		writeLockInprogress = false;
		writer = Thread.currentThread();
	}

	public synchronized void releaseWrite() {
		numWriters--;
		writer = null;
		notifyAll();
	}

	private boolean canRead() {
		if (numWriters == 0 && !writeLockInprogress) {
			return true;
		}
		return false;
	}

	private boolean canWrite() {
		if (numWriters == 0 && numReaders == 0) {
			return true;
		}
		return false;
	}
	
	/* Record the thread which got the lock. */
	private void addToMap(Map<Thread, Integer> m) {
		Integer count = m.get(Thread.currentThread());
		if (count == null) {
			count = new Integer(1);
			readers.put(Thread.currentThread(), count);
		} else {
			Integer newCount = new Integer(count.intValue() + 1);
			readers.put(Thread.currentThread(), newCount);
		}
	}
	
	/* Remove thread from the records */
	private void removeFromMap(Map<Thread, Integer> m) {
		Integer count = m.get(Thread.currentThread());
		if (count != null) {
			Integer newCount = new Integer(count.intValue() - 1);
			readers.put(Thread.currentThread(), newCount);
		}
	}
	
	private boolean hasReadLock() {
		Integer count = readers.get(Thread.currentThread());
		if (count != null) {
			return true;
		}
		return false;
	}
	
	private boolean hasWriteLock() {
		return (writer == Thread.currentThread());
	}
}
