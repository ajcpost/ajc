package aj.thread.gotchas;

import java.util.LinkedList;

// TODO Sync gotcha - black-hole
// Actual buffer is wrapped in another buffer which also has synchronized
// get, add methods.
// Consumer calls wrapper and locks the monitor on wrapper object since
// queue is empty
// Producer calls wrapper to add an item but can't get lock.
/**
 * Title: Black-hole due to multiple synchronization.
 * 
 * Description: Main thread calls the get() which in turn calls the get() of the
 * wrapped object and acquires a lock on that object. The child thread calls
 * add() which again calls
 * 
 * Outcome: Program should never display "Clean exit".
 */
public class WrappedBufferDeadlock implements IGotcha {

    private final Buffer m_b = new Buffer();

    synchronized public void add(Object o) throws InterruptedException {
	m_b.add(o);
    }

    synchronized public Object get() throws InterruptedException {
	return m_b.get();
    }

    public void execute() {
	Thread t = new Thread_WrappedBufferDeadlock("ProblemThread");

	try {

	    System.out.println("Starting produce thread to put an item...");
	    t.start();

	    System.out.println("Main acquiring get lock...");
	    m_b.get();

	    // Doing clean up. Won't reach this line.
	    t.interrupt();
	    System.out.println("Clean exit");
	} catch (Exception e) {
	    System.out.println(e);
	}
    }

    // Actual wrapped impl of buffer
    private class Buffer {
	private final LinkedList<Object> m_queue = new LinkedList<Object>();

	synchronized public void add(Object o) throws InterruptedException {
	    m_queue.add(o);
	    this.notifyAll();
	}

	synchronized public Object get() throws InterruptedException {
	    while (m_queue.size() == 0) {
		wait();
	    }
	    return m_queue.removeFirst();
	}
    }

    private class Thread_WrappedBufferDeadlock extends Thread {

	private final String m_name;

	Thread_WrappedBufferDeadlock(String name) {
	    m_name = name;
	}

	@Override
	synchronized public void run() {
	    System.out.println(m_name + " ready to run...");
	    while (true) {
		try {
		    System.out.println("Producer adding to buffer...");
		    Thread.sleep(10000);
		    m_b.add(Integer.valueOf(10));
		} catch (InterruptedException e) {
		    e.printStackTrace();
		}
	    }
	}

    }
}