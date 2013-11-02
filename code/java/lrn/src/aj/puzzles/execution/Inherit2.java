package aj.puzzles.execution;

import java.io.IOException;

/**
 * "Checked exceptions a method can throw is the intersection, not union"
 * 
 * Since it's intersection, not union, compile won't enforce that f1 throw or
 * catch both the exceptions.
 * 
 */

// Would the program compile? Shouldn't f1 in Inherit either throw both the
// checked exceptions or catch it?
public class Inherit2 implements If3 {
    public void f1() {
	System.out.println("Hello world");
    }

    public static void main(String[] args) {
	If3 i3 = new Inherit2();
	i3.f1();
    }
}

interface If1 {
    void f1() throws IOException;
}

interface If2 {
    void f1() throws InterruptedException;
}

interface If3 extends If1, If2 {
}