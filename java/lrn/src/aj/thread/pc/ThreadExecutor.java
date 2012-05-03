package aj.thread.pc;

public final class ThreadExecutor extends Thread {

    private final ICommand m_command;
    private final int m_sleepMilliSeconds = 10;

    public ThreadExecutor(ICommand c, String name) {
	setName(name);
	m_command = c;
    }

    @Override
    public void run() {
	while (true) {
	    try {
		// The statement will not be displayed if the execute calls is
		// blocked on a resource.
		System.out.println(getName() + " executing - "
			+ m_command.execute());
		Thread.sleep(m_sleepMilliSeconds);
	    } catch (InterruptedException e) {
		e.printStackTrace();
		Thread.currentThread().interrupt();
	    }
	}

    }
}
