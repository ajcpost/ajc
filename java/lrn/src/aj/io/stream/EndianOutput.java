package aj.io.stream;

import java.io.*;

/**
 * Java stores int in big-endian order. To convert these to small-endian order,
 * each 8bits are taken out separately and added to a byte
 * 
 */
public class EndianOutput {

    public static void main(String[] args) throws IOException {
	DataOutputStream ds = new DataOutputStream(System.out);
	int val = 1;

	int byteArray[] = new int[4];
	byteArray[0] = val & 0xFF;
	byteArray[1] = (val >>> 8) & 0xFF;
	byteArray[2] = (val >>> 16) & 0xFF;
	byteArray[3] = (val >>> 24) & 0xFF;

	ds.writeChars("Bytes:\n");
	for (int i = 0; i < byteArray.length; i++) {
	    System.out.print("[byte" + i + " is: ");
	    ds.writeByte(byteArray[i]);
	    System.out.print("]");
	    System.out.printf(" [as hex: %x]\n", byteArray[i]);
	}
	ds.flush();
	ds.close();
    }
}
