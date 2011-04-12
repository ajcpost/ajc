package aj.thread.gotchas;

import java.util.Arrays;

/**
 * Title: Arrays are mutable.
 * 
 * Description: States array in main is passed to child threads which end up
 * modifying it. Correct way would be to provide an iterator for looping through
 * the array.
 * 
 * Outcome: Program should display changed values for the state array.
 */
public final class UnsafeStates implements IGotcha {

    private final static String m_unsafeStates[] = { "s", "s", "s", "s", "s" };

    public void execute() {

	System.out.print("Before passing to threads ..."
		+ Arrays.toString(m_unsafeStates));
	System.out.println();

	for (int i = 0; i < 4; i++) {
	    Thread t = new Thread_UnsafeStates(m_unsafeStates);
	    t.start();
	}

	try {
	    Thread.sleep(5000);
	} catch (InterruptedException e) {
	    e.printStackTrace();
	}

	System.out.print("After passing to threads ..."
		+ Arrays.toString(m_unsafeStates));
	System.out.println();
    }

    private final class Thread_UnsafeStates extends Thread {

	private final String[] m_states;

	Thread_UnsafeStates(String[] states) {
	    m_states = states;
	}

	@Override
	public void run() {
	    try {
		for (int i = 0; i < m_states.length; i++) {
		    m_states[i] = "s" + Thread.currentThread().getId();
		    Thread.sleep(1000);
		}
	    } catch (InterruptedException e) {
		e.printStackTrace();
	    }

	}

    }

}