package temp;

public class Histogram {

    private static int mod(int i, int modulus) {
	int result = i % modulus;
	return result < 0 ? result + modulus : result;
    }

    public static void main(String[] args) {

	final int MODULUS = 3;
	int[] histogram = new int[MODULUS];
	int i = Integer.MIN_VALUE;
	do {
	    histogram[Histogram.mod(i, MODULUS)]++;
	} while (i++ != Integer.MAX_VALUE);

	for (i = 0; i < histogram.length; i++) {
	    System.out.println(histogram[i]);
	}
    }
}
