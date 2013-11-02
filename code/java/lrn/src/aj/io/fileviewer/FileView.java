package aj.io.fileviewer;

import javax.swing.*;
import java.io.*;
import java.awt.*;
import java.awt.event.*;
import java.nio.charset.*;
import java.util.*;

/**
 * Credit: Javaª I/O, 2nd Edition (Elliotte Rusty Harold)
 * 
 */
@SuppressWarnings("serial")
public class FileView extends JFrame implements ActionListener {
    JFileChooser filechooser = new JFileChooser();
    JWritableTextArea theView = new JWritableTextArea();
    TextModePanel mp = new TextModePanel();


    public static void main(String[] args) {
	FileView viewer = new FileView();
	viewer.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	viewer.setVisible(true);
    }

    public FileView() {
	super("FileView");

	filechooser.setApproveButtonText("View File");
	filechooser.setApproveButtonMnemonic('V');
	filechooser.addActionListener(this);
	this.getContentPane().add(BorderLayout.EAST, filechooser);
	JScrollPane sp = new JScrollPane(theView);
	sp.setPreferredSize(new Dimension(640, 400));
	this.getContentPane().add(BorderLayout.SOUTH, sp);
	this.getContentPane().add(BorderLayout.WEST, mp);
	this.pack();
	// Center on display
	Dimension display = getToolkit().getScreenSize();
	Dimension bounds = this.getSize();
	int x = (display.width - bounds.width) / 2;
	int y = (display.height - bounds.height) / 2;
	if (x < 0)
	    x = 10;
	if (y < 0)
	    y = 15;
	this.setLocation(x, y);
    }

    public void actionPerformed(ActionEvent evt) {
	if (evt.getActionCommand().equals(JFileChooser.APPROVE_SELECTION)) {
	    File f = filechooser.getSelectedFile();
	    if (f != null) {
		theView.reset();
		try {
		    DumpFile.dump(f, theView.getWriter(), mp
			    .getDisplayOptions());
		} catch (IOException ex) {
		    JOptionPane.showMessageDialog(this, ex.getMessage(),
			    "I/O Error", JOptionPane.ERROR_MESSAGE);
		}
	    }
	} else if (evt.getActionCommand().equals(JFileChooser.CANCEL_SELECTION)) {
	    this.setVisible(false);
	    this.dispose();
	    // This is a single window application
	    System.exit(0);
	}
    }
}

@SuppressWarnings("serial")
class JWritableTextArea extends JTextArea {

    private Writer writer = new BufferedWriter(new TextAreaWriter());

    public JWritableTextArea() {
	this("", 0, 0);
    }

    public JWritableTextArea(String text) {
	this(text, 0, 0);
    }

    public JWritableTextArea(int rows, int columns) {
	this("", rows, columns);
    }

    public JWritableTextArea(String text, int rows, int columns) {
	super(text, rows, columns);
	setFont(new Font("Monospaced", Font.PLAIN, 12));
	setEditable(false);
    }

    public Writer getWriter() {
	return writer;
    }

    public void reset() {
	this.setText("");
	writer = new BufferedWriter(new TextAreaWriter());
    }

    private class TextAreaWriter extends Writer {
	private boolean closed = false;

	@Override
	public void close() {
	    closed = true;
	}

	@Override
	public void write(char[] text, int offset, int length)
		throws IOException {
	    if (closed)
		throw new IOException("Write to closed stream");
	    JWritableTextArea.this.append(new String(text, offset, length));
	}

	@Override
	public void flush() {
	}
    }
}

@SuppressWarnings("serial")
class TextModePanel extends JPanel {
    private JCheckBox bigEndian = new JCheckBox("Big Endian", true);
    private JCheckBox deflated = new JCheckBox("Deflated", false);
    private JCheckBox gzipped = new JCheckBox("GZipped", false);
    private ButtonGroup dataTypes = new ButtonGroup();
    private JRadioButton asciiRadio = new JRadioButton("Text");
    private JRadioButton decimalRadio = new JRadioButton("Decimal");
    private JRadioButton hexRadio = new JRadioButton("Hexadecimal");
    /*
     * private JRadioButton shortRadio = new JRadioButton("Short"); private
     * JRadioButton intRadio = new JRadioButton("Int"); private JRadioButton
     * longRadio = new JRadioButton("Long"); private JRadioButton floatRadio =
     * new JRadioButton("Float"); private JRadioButton doubleRadio = new
     * JRadioButton("Double");
     */
    private JTextField password = new JPasswordField();
    private JList encodings = new JList();

    public TextModePanel() {
	Map charsets = Charset.availableCharsets();
	encodings.setListData(charsets.keySet().toArray());
	this.setLayout(new GridLayout(1, 2));
	JPanel left = new JPanel();
	JScrollPane right = new JScrollPane(encodings);
	left.setLayout(new GridLayout(13, 1));
	left.add(bigEndian);
	left.add(deflated);
	left.add(gzipped);
	left.add(asciiRadio);
	asciiRadio.setSelected(true);
	left.add(decimalRadio);
	left.add(hexRadio);
	/*
	 * left.add(shortRadio); left.add(intRadio); left.add(longRadio);
	 * left.add(floatRadio); left.add(doubleRadio);
	 */
	dataTypes.add(asciiRadio);
	dataTypes.add(decimalRadio);
	dataTypes.add(hexRadio);
	/*
	 * dataTypes.add(shortRadio); dataTypes.add(intRadio);
	 * dataTypes.add(longRadio); dataTypes.add(floatRadio);
	 * dataTypes.add(doubleRadio);
	 */
	left.add(password);
	this.add(left);
	this.add(right);
    }

    public DisplayOptions getDisplayOptions() {
	DisplayOptions options = new DisplayOptions(getDataType(),
		isBigEndian(), isDeflated(), isGZipped(), getPassword(),
		getEncoding());
	return options;
    }

    private boolean isBigEndian() {
	return bigEndian.isSelected();
    }

    private boolean isDeflated() {
	return deflated.isSelected();
    }

    private boolean isGZipped() {
	return gzipped.isSelected();
    }

    private String getPassword() {
	return password.getText();
    }

    private String getEncoding() {
	return (String) encodings.getSelectedValue();
    }

    private DataType getDataType() {
	if (asciiRadio.isSelected())
	    return DataType.ASC;
	else if (decimalRadio.isSelected())
	    return DataType.DEC;
	else if (hexRadio.isSelected())
	    return DataType.HEX;
	/*
	 * else if (shortRadio.isSelected()) return DataType.SHORT; else if
	 * (intRadio.isSelected()) return DataType.INT; else if
	 * (longRadio.isSelected()) return DataType.LONG; else if
	 * (floatRadio.isSelected()) return DataType.FLOAT; else if
	 * (doubleRadio.isSelected()) return DataType.DOUBLE;
	 */
	else
	    return DataType.ASC;
    }

    /*
     * private boolean isText() { if (this.getDataType() == DataType.ASC) return
     * true; return false; }
     */

}