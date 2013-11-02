package aj.puzzles.execution;

/**
 * "Thread will not execute unless t.start() is called"
 * 
 * The issue here is that t.start() is never called (and hence no other thread
 * is instantiated), instead t.run() is. t.run() is executed in the same thread
 * and thus all of the execution is sequential and the program always displays
 * PongPing.
 * 
 */

// What's the output of the following program?
public class Sync1 {
    public static synchronized void main(String[] a) {
	Thread t = new Thread() {
	    public void run() {
		pong();
	    }
	};
	t.run();
	System.out.print("Ping");
    }

    static synchronized void pong() {
	System.out.print("Pong");
    }
}
