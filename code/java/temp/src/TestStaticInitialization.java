

import java.util.Calendar;

public class TestStaticInitialization {

    public static final TestStaticInitialization INSTANCE = new TestStaticInitialization();
    private final int beltSize;
    private static final int CURRENT_YEAR = Calendar.getInstance().get(
	    Calendar.YEAR);

    private TestStaticInitialization() {
	beltSize = CURRENT_YEAR - 1930;
    }

    public int beltSize() {
	return beltSize;
    }

    public static void main(String[] args) {
	System.out.println("Size  is" + INSTANCE.beltSize() + " belt.");
    }
}
