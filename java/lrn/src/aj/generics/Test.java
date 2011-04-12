package generics;

import java.util.*;

public class Test {

    /**
     * @param args
     */
    public static void main(String[] args) {

	List<? super Integer> nums1 = new LinkedList<Integer>();
	nums1.add(3);
	Integer val1 = nums1.get(0);

	List<? extends Integer> nums2 = new LinkedList<Integer>();
	nums2.add(new Integer(1));
	Integer val2 = nums2.get(0);
	
    }

    /*
     * public static int foo () { return 5; } public static String foo () {
     * return "bla"; }
     * 
     * public static int sum(List<Integer> ints) { int sum = 0; for (int i :
     * ints) sum += i; return sum; }
     * 
     * public static String sum(List<String> strings) { StringBuffer sum = new
     * StringBuffer(); for (String s : strings) sum.append(s); return
     * sum.toString(); }
     */
}