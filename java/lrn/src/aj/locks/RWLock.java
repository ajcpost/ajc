package aj.locks;

public interface RWLock {
	
	public void acquireRead () throws InterruptedException;
	public void releaseRead ();	
	public void acquireWrite () throws InterruptedException;
	public void releaseWrite ();

}
