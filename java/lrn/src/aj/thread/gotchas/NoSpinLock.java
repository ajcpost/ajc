package aj.thread.gotchas;

import java.util.LinkedList;

/**
 * Title: Missing spin lock.
 * 
 * Description: Read threads do "if (empty)" check during get instead of
 * "while (empty)". When the write thread calls notfiyAll(), all read threads
 * are woken up but only one of them will get lock and will retrieve the object.
 * All other read threads will get an exception NoSuchElement.
 * 
 * Outcome: All but one read thread will die. Program will continue with just
 * one reader and writer.
 */

public final class NoSpinLock implements IGotcha {
    private final LinkedList<Object> m_queue = new LinkedList<Object>();

    synchronized private void add(Object o) throws InterruptedException {
	m_queue.add(o);
	this.notifyAll();
    }

    synchronized private Object get() throws InterruptedException {
	if (m_queue.size() == 0) {
	    // while (m_queue.size() == 0) {
	    wait();
	}
	return m_queue.removeFirst();
    }

    public void execute() {

	for (int i = 0; i < 3; i++) {
	    Thread t = new ReadThread_NoSpinLock("Reader-" + i);
	    t.start();
	}
	for (int i = 0; i < 1; i++) {
	    Thread t = new WriteThread_NoSpinLock("Writer-" + i);
	    t.start();
	}
    }

    private final class ReadThread_NoSpinLock extends Thread {

	public ReadThread_NoSpinLock(String name) {
	    setName(name);
	}

	@Override
	public void run() {
	    while (true) {
		try {
		    System.out.println("Thread ID: "
			    + Thread.currentThread().getName()
			    + " Object value:" + get().toString());
		    Thread.sleep(100);
		} catch (InterruptedException e) {
		    e.printStackTrace();
		}
	    }

	}
    }

    private class WriteThread_NoSpinLock extends Thread {

	public WriteThread_NoSpinLock(String name) {
	    setName(name);
	}

	@Override
	public void run() {
	    int i = 1;
	    while (true) {
		try {
		    System.out.println("Adding object" + Integer.valueOf(i));
		    add(Integer.valueOf(i++));
		    Thread.sleep(100);
		} catch (InterruptedException e) {
		    e.printStackTrace();
		}
	    }

	}

    }
}