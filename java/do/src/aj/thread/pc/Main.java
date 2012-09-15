package aj.thread.pc;

import java.util.Arrays;

final class Main {

    public static void main(String[] args) throws IllegalArgumentException {

	if (args.length != 3) {
	    throw new IllegalArgumentException(
		    "Usage: Main <buffer-type> <num-producer> <num-consumer>, received " +  Arrays.toString(args));
	}

	try {
	    System.out.println ("Executing : "+ Arrays.toString(args));
	    Thread.sleep (1000);

	    IBuffer b = BufferFactory.getBufferInstance(args[0]);
	    ICommand consumer = new CommandConsume(b);
	    ICommand producer = new CommandProduce(b);

	    int noConsumer = Integer.parseInt(args[2]);
	    for (int i = 0; i < noConsumer; i++) {
		Thread t = new ThreadExecutor(consumer, "c" + i);
		t.start();
	    }

	    int noProducer = Integer.parseInt(args[1]);
	    for (int i = 0; i < noProducer; i++) {
		Thread t = new ThreadExecutor(producer, "p" + i);
		t.start();
	    }
	} catch (Exception e) {
	    System.out.println(e);
	    System.exit(-1);
	}
    }

    private final static class BufferFactory {

	static final IBuffer b2SphoreSync = new Buffer2SphoreSync();
	static final IBuffer bConcurrentBlocking = new BufferConcurrentBlocking();
	static final IBuffer bReentrantLock = new BufferReentrantLock();
	static final IBuffer bSphoreNosync = new Buffer2SphoreNosync();
	static final IBuffer bNormalSync = new BufferNormalSync();

	private enum BufferEnum {
	    Buffer2SphoreSync(b2SphoreSync), BufferConcurrentBlocking(
		    bConcurrentBlocking), BufferReentrantLock(bReentrantLock), Buffer2SphoreNosync(
		    bSphoreNosync), BufferNormalSync(bNormalSync);

	    private final IBuffer buffer;

	    BufferEnum(IBuffer buffer) {
		this.buffer = buffer;
	    }
	}

	private static final IBuffer getBufferInstance(String bName) {
	    for (BufferEnum b : BufferEnum.values()) {
		if (b.toString().equals(bName))
		    return b.buffer;
	    }
	    throw new IllegalArgumentException("Unsupported buffer type:" + bName);
	}

    }

}
