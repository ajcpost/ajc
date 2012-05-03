package aj.thread.pc;

//execute() method is intentionally not made thread-safe.
public final class CommandConsume implements ICommand {

    private final IBuffer m_b;
    private final static String s_name = "consumer";

    public CommandConsume(IBuffer b) {
	m_b = b;
    }

    public Object execute() throws InterruptedException {
	return m_b.get();
    }

    public String getName() {
	return s_name;
    }
}
