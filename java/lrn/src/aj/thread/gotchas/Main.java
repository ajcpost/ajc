package aj.thread.gotchas;

import java.util.Arrays;

public class Main {

    public static void main(String[] args) throws IllegalArgumentException {

	if (args.length != 1) {
	    throw new IllegalArgumentException(
		    "Usage: Main <problem-name>, received "
			    + Arrays.toString(args));
	}

	try {
	    System.out.println("Executing : " + Arrays.toString(args));
	    Thread.sleep(1000);

	    IGotcha g = GotchaFactory.getGotchaInstance(args[0]);
	    g.execute();
	} catch (Exception e) {
	    System.out.println(e);
	    System.exit(-1);
	}
    }
    
    private final static class GotchaFactory {

	static IGotcha g_noSpinLock = new NoSpinLock();
	static IGotcha g_synchronizedRun = new SynchronizedRun();
	static IGotcha g_unsafeSeqGenerator = new UnsafeSeqGenerator();
	static IGotcha g_unsafeStates = new UnsafeStates();
	static IGotcha g_unsuncExitSignal = new UnsyncExitSignal();
	static IGotcha g_wrappedBufferDeadlock = new WrappedBufferDeadlock();

	private enum ProblemEnum {
	    NoSpinLock(g_noSpinLock), SynchronizedRun(g_synchronizedRun), UnsafeSeqGenerator(
		    g_unsafeSeqGenerator), UnsafeStates(g_unsafeStates), UnsyncExitSignal(
		    g_unsuncExitSignal), WrappedBufferDeadlock(
		    g_wrappedBufferDeadlock);

	    private final IGotcha gotcha;

	    ProblemEnum(IGotcha gotcha) {
		this.gotcha = gotcha;
	    }
	}

	private static IGotcha getGotchaInstance(String problemName) {
	    for (ProblemEnum problem : ProblemEnum.values()) {
		if (problemName.equals(problem.toString()))
		    return problem.gotcha;
	    }
	    throw new IllegalArgumentException("Unsupported problem:"
		    + problemName);
	}
    }

}
