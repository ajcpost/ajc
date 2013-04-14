package aj.thread.pc;

import java.util.concurrent.Semaphore;
import java.util.LinkedList;

/**
 * Title: Separate semaphores and Q synchronization.
 * 
 * Description: Producer uses m_full semaphore to block during add operation
 * while consumer uses m_empty to block during read. Underlying
 * queue (LinkedList) operations are synchronized.
 * 
 * Outcome: The program is fully functional.
 */

final class Buffer2SphoreSync implements IBuffer {

    private final static int s_qSize = 10;
    private final Semaphore m_empty = new Semaphore(0);
    private final Semaphore m_full = new Semaphore(s_qSize);
    private final LinkedList<Object> m_queue = new LinkedList<Object>();

    public void add(Object o) throws InterruptedException {
	waitIfFull();
	synchronized (this) {
	    m_queue.add(o);
	}
	indicateData();
    }

    public Object get() throws InterruptedException {
	waitIfEmpty();
	Object val;
	synchronized (this) {
	    val = m_queue.removeFirst();
	}
	indicateSpace();
	return val;
    }

    private void waitIfEmpty() throws InterruptedException {
	m_empty.acquire();
    }

    private void waitIfFull() throws InterruptedException {
	m_full.acquire();
    }

    private void indicateData() {
	m_empty.release();
    }

    private void indicateSpace() {
	m_full.release();
    }
}
