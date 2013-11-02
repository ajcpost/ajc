package aj.puzzles.flowofcontrol;

/**
 * "Be aware of boundary conditions.
 * 
 * All integers are always less than or equal to MAX_VALUE so the for exit
 * condition will never be true. When the integer reaches MAX_VALUE, it's
 * automatically wrapped back to min value.
 * 
 */

// What's the output of the following program?
public class Loop2 {
    public static final int s_begin = Integer.MAX_VALUE - 50;

    public static void main(String[] args) {
	int count = 0;
	for (int i = s_begin; i <= Integer.MAX_VALUE; i++)
	    count++;
	System.out.println(count);
    }
}