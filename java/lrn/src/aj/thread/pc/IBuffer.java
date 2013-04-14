package aj.thread.pc;

public interface IBuffer {

    public void add(Object o) throws InterruptedException;

    public Object get() throws InterruptedException;

}
