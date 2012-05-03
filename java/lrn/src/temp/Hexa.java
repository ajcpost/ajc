package temp;

public class Hexa {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		int values[] = { 5566788, 9292, 100000000, 763472342, 88342, 10, 15 };
		
		for (int value : values)
		{
			String str = Integer.toHexString(value);
			System.out.println (value + " : " + str);
			
		}

	}

}
