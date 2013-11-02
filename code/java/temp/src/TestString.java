import java.io.UnsupportedEncodingException;


public class TestString {

	public static void main (String[] args) {
		String val=null;
		try {
			//val = f1 (new String("abcädef ♠clean".getBytes("UTF-8")));
			val = f1 (new String("àèÈà€é".getBytes("UTF-8")));
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println ("val after:" + val);
	}
	
	private static String f1 (String input) {
		System.out.println ("val before:" + input);
		return input.getBytes().toString();
	}
}
