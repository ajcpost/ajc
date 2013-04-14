package aj.thread.gotchas;

/**
 * Title: "++" operation is not thread safe.
 * 
 * Description: Multiple threads do a getNext() and since "++" is not thread
 * safe, will end up missing some sequences.
 * 
 * Outcome: May not be easily observable but output should have missing sequence
 * numbers.
 */
public final class UnsafeSeqGenerator implements IGotcha {

    private int m_seq = -1;

    private int getNext() {
	++m_seq;
	return m_seq;
    }

    public void execute() {
	for (int i = 0; i < 30; i++) {
	    Thread t = new Thread_UnsafeSeqGenerator();
	    t.start();
	}
    }

    private class Thread_UnsafeSeqGenerator extends Thread {

	@Override
	public void run() {
	    while (true) {
		try {
		    System.out.println("Sequence value:" + getNext());
		    Thread.sleep(10);
		} catch (InterruptedException e) {
		    e.printStackTrace();
		}
	    }
	}
    }
}