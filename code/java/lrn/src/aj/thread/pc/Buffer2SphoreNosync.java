package aj.thread.pc;

import java.util.LinkedList;
import java.util.concurrent.Semaphore;

/**
 * Title: Separate semaphores but no Q synchronization.
 * 
 * Description: Producer uses m_full semaphore to block during add operation
 * while consumer uses m_empty to block during read. However, the underlying
 * queue (LinkedList) is not synchronized and hence the add/remove operations
 * can get into thread safety issues.
 * 
 * Outcome: The program has been observed to receive NoSuchElementException
 * during read operation, esp when no. of threads are (2,10)
 * (producer,consumer), Q size is 10 and sleep time in ThreadExecutor is 10ms.
 */

final class Buffer2SphoreNosync implements IBuffer {

    private static final int s_qSize = 10;
    private final Semaphore m_empty = new Semaphore(0);
    private final Semaphore m_full = new Semaphore(s_qSize);
    private final LinkedList<Object> m_queue = new LinkedList<Object>();

    public void add(Object o) throws InterruptedException {
	waitIfFull();
	m_queue.add(o);
	indicateData();
    }

    public Object get() throws InterruptedException {
	waitIfEmpty();
	Object val;
	val = m_queue.removeFirst();
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