package aj.thread.pc;

public interface ICommand {

    public Object execute() throws InterruptedException;

    public String getName();

}
