package aj.thread.pc;

// execute() method is intentionally not made thread-safe.
public final class CommandProduce implements ICommand {

    private final IBuffer m_b;
    private final static String s_name = "producer";
    private static int s_counter = 0;

    public CommandProduce(IBuffer b) {
	m_b = b;
    }

    public Object execute() throws InterruptedException {
	++s_counter;
	m_b.add(Integer.valueOf(s_counter));
	return Integer.valueOf(s_counter);
    }

    public String getName() {
	return s_name;
    }

}
