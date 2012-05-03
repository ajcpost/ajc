package aj.thread.pc;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ArrayBlockingQueue;

/**
 * Title: Using the util.concurrent Q instead of semaphores.
 * 
 * Description: 
 * 
 * Outcome: Program is fully functional.
 */

final class BufferConcurrentBlocking implements IBuffer {

    private final static int s_qSize = 10;
    private final BlockingQueue<Object> m_queue = new ArrayBlockingQueue<Object>(
	    s_qSize);

    public void add(Object o) throws InterruptedException {
	m_queue.add(o);
    }

    public Object get() throws InterruptedException {
	return m_queue.take();
    }

}
