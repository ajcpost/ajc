package aj.thread.pc;

import java.util.LinkedList;

/**
 * Title: Ordinary synchronized impl without semaphores.
 * 
 * Description: Consumer uses "if (m_queue.size() == 0) then wait" construct to
 * wait on empty queue. Assuming the "if condition" is true but before consumer
 * enters wait(), a context switch happens and producer produces an item,
 * issuing notify(). Since no consumer is actually in wait(), this notification
 * is lost. Producer will now wait because Q is full and consumer will also wait
 * since it "thinks" that Q is empty.
 * 
 * Outcome: Deadlock when no. of threads are (1,1) (producer,consumer), Q size
 * is 1.
 */

final class BufferNormalSync implements IBuffer {
    private final static int s_qSize = 1;
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
	if (m_queue.size() == 0) {
	    Thread.sleep(1000);
	    synchronized (this) {
		wait();
	    }
	}
    }

    private void waitIfFull() throws InterruptedException {
	if (m_queue.size() == s_qSize)
	    synchronized (this) {
		wait();
	    }
    }

    private void indicateData() {
	synchronized (this) {
	    notify();
	}
    }

    private void indicateSpace() {
	synchronized (this) {
	    notify();
	}
    }

}
