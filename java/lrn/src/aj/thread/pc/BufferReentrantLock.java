package aj.thread.pc;

import java.util.LinkedList;
import java.util.concurrent.locks.*;

/**
 * Title: Using the util.concurrent reentrant locks
 * 
 * Description: 
 * 
 * Outcome: Program is fully functional.
 */
final class BufferReentrantLock implements IBuffer {

    private final Lock lock = new ReentrantLock();
    private final Condition notFull = lock.newCondition();
    private final Condition notEmpty = lock.newCondition();
    private final static int s_qSize = 1;
    private final LinkedList<Object> m_queue = new LinkedList<Object>();

    public void add(Object o) throws InterruptedException {
	lock.lock();
	try {
	    while (s_qSize == m_queue.size()) {
		notFull.await();
	    }
	    m_queue.add(o);
	    notEmpty.signal();
	} finally {
	    lock.unlock();
	}
    }

    public Object get() throws InterruptedException {
	lock.lock();
	try {
	    while (0 == m_queue.size()) {
		notEmpty.await();
	    }
	    Object o = m_queue.removeFirst();
	    notFull.signal();
	    return o;
	} finally {
	    lock.unlock();
	}
    }

}
