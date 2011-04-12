package aj.puzzles.execution;

import java.math.BigInteger;

/**
 * "Beware of mutability of library classes"
 * 
 * BigInteger is immutable and hence every add() operation returns another
 * instance of BigInteger instead of adding it to "total".
 */

// What's the output of the following program?
public class DoSum {

    public static void main(String[] args) {
	BigInteger b1 = new BigInteger("1000");
	BigInteger b2 = new BigInteger("10000");

	BigInteger sum = BigInteger.ZERO;
	sum.add(b1);
	sum.add(b2);

	System.out.println(sum);
    }
}
