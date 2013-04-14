package aj.locks.impl;

import aj.locks.RWLock;

/**
 * Plain, non-reentrant implementation
 * 
 * (Read lock)
 * - Grant if no thread has acquired write lock or is requesting one
 * (Write lock) 
 * - Grant if no thread has acquired write lock or read lock
 * - Give priority to write lock if a read & write request is made simultaneously
 * 
 * Why reentrant?
 * - A thread that has write request and issues acquire again will block
 * - Other deadlock situations:
 *   - T1 acquires read lock
 *   - T2 requests write lock and is blocked but has set writeLockInProgress
 *   - T1 reissues read lock request. It will block because writeLockInProgress is set.
 *   - No thread will get any lock any more.
 * 
 *
 */
public class RWLockPlain implements RWLock {

	private int numReaders = 0;
	private int numWriters = 0;
	private boolean writeLockInprogress = false;

    public synchronized void acquireRead() throws InterruptedException {
		while (!canRead()) {
			wait();
		}
		numReaders++;
	}

	 public synchronized void releaseRead() {
		numReaders--;
		notifyAll();
	}

	 public synchronized void acquireWrite() throws InterruptedException {

		writeLockInprogress = true;
		while (!canWrite()) {
			wait();
		}
		numWriters++;
		writeLockInprogress = false;
	}

	 public synchronized void releaseWrite() {
		numWriters--;
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
}
