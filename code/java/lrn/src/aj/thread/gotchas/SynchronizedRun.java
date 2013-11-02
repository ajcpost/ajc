package aj.thread.gotchas;

/**
 * Title: Run method is synchronized.
 * 
 * Description: Child threads ends up acquiring a lock on the object since run
 * is synchronized. The lock is never released (even during Thread.sleep) and
 * hence when main calls another synchronized method (changeState()), it blocks.
 * 
 * Outcome: Program should never display "Clean exit" and main should never be
 * able to loop more than once.
 */
public final class SynchronizedRun implements IGotcha {

    public void execute() {
	Thread_SynchronizedRun t = new Thread_SynchronizedRun(
		"SynchronizedRunThread");
	t.start();

	for (int i = 0; i < 10; i++) {
	    System.out.println("Main can't loop more than once..." + i++);
	    t.changeState();
	}

	t.interrupt();
	System.out.println("Clean exit");
    }

    private final class Thread_SynchronizedRun extends Thread {

	private int counter1 = 0;

	Thread_SynchronizedRun(String name) {
	    setName(name);
	}

	@Override
	synchronized public void run() {
	    while (true) {
		try {
		    System.out.println(getName() + ", Counter1: "
			    + counter1++);
		    Thread.sleep(1000);
		} catch (InterruptedException e) {
		    e.printStackTrace();
		}
	    }

	}

	synchronized public void changeState() {
	    counter1 = -100;
	}

    }
}