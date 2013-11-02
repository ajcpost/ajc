package aj.effectivej.annotations;

//Program containing annotations with a parameter - Page 172

import java.util.*;
import java.lang.ArrayStoreException;

public class Sample2 {
    @ExceptionTest(ArithmeticException.class)
    public static void m1() {  // Test should pass
        int i = 0;
        i = i / i;
    }
    @ExceptionTest(ArithmeticException.class)
    public static void m2() {  // Should fail (wrong exception)
        int[] a = new int[0];
        int i = a[1];
    }
    @ExceptionTest(ArithmeticException.class)
    public static void m3() { }  // Should fail (no exception)
    
    public static void m4() { } // No annotation
    
    @ExceptionTest(ArithmeticException.class)
    public static void m5() { throw new ArrayStoreException(); } // Different exception


    // Code containing an annotation with an array parameter - Page 174
    @ExceptionTest({ IndexOutOfBoundsException.class,
                NullPointerException.class })
    public static void doublyBad() {
        List<String> list = new ArrayList<String>();

        // The spec permits this method to throw either
        // IndexOutOfBoundsException or NullPointerException
        list.addAll(5, null);
    }
}