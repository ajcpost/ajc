package aj.thread.gotchas;

/**
 * Title: Object visibility issue.
 * 
 * Description: If field access is not synchronized, it's possible that a thread
 * may never see the updates done by another thread. In this case, the child
 * thread may never see that main thread is signaling it to quit. Always use
 * synchronization (or volatile keyword) for such cases.
 * 
 * Outcome: May not be easily observable but program should never display
 * "Clean exit".
 */
public class UnsyncExitSignal implements IGotcha {

    public void execute() {
	Thread_UnSyncExitSignal t = new Thread_UnSyncExitSignal(
		"NeverGetsQuitSignalThread");
	t.start();
	try {
	    Thread.sleep(1000);
	    t.setDone();
	    while (t.getState() != Thread.State.TERMINATED) {
		System.out.println("Main waiting for child thread to exit...");
		Thread.sleep(100);
	    }
	    System.out.println("Clean exit");
	} catch (InterruptedException e) {
	    e.printStackTrace();
	}
    }

    private class Thread_UnSyncExitSignal extends Thread {

	private boolean done = false;

	Thread_UnSyncExitSignal(String name) {
	    setName(name);
	}

	@Override
	public void run() {
	    while (!done) {
		try {
		    System.out.println(getName() + " looping...");
		    Thread.sleep(100);
		} catch (InterruptedException e) {
		    e.printStackTrace();
		}
	    }
	    System.out.println(getName() + " exit flag set to true, stopping");

	}

	public void setDone() {
	    done = true;
	}

    }
}