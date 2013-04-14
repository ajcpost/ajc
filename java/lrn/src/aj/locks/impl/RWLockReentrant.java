package aj.locks.impl;

import aj.locks.RWLock;
import java.util.*;

/**
 * Fully reentrant implementation
 * 
 * (Read lock)
 * - Grant if no thread has acquired write lock or is requesting one
 * - Grant if the same thread has write lock
 * - Don't block if the thread already has read lock
 * - 
 * (Write lock) 
 * - Grant if no thread has acquired write lock or read lock
 * - Grant if the same thread has read lock
 * - Don't block if the thread already has write lock
 * - Give priority to write lock if a read & write request is made simultaneously
 * 
 */
public class RWLockEnt implements RWLock {

	private int numReaders = 0;
	private int numWriters = 0;
	private boolean writeLockInprogress = false;
	private Map<Thread, Integer> readers = new HashMap<Thread, Integer>();
	private Thread writer = null;

	public synchronized void acquireRead() throws InterruptedException {
		while (!canAllowRead()) {
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
		while (!canAllowWrite()) {
			wait();
		}
		numWriters++;
		writeLockInprogress = false;
		writer = Thread.currentThread();
	}

	public synchronized void releaseWrite() {
		numWriters--;
		notifyAll();
		writer = null;
	}

	protected boolean canAllowRead() {
		if (numWriters > 0 || writeLockInprogress || alreadyHasReadLock()) {
			return false;
		} else {
			return true;
		}
	}

	protected boolean canAllowWrite() {
		if (numReaders > 0 || numWriters > 0 || alreadyHasWriteLock()) {
			return false;
		} else {
			return true;
		}
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
	
	private boolean alreadyHasReadLock() {
		Integer count = readers.get(Thread.currentThread());
		if (count != null) {
			return true;
		}
		return false;
	}
	
	private boolean alreadyHasWriteLock() {
		return (writer == Thread.currentThread());
	}
}
