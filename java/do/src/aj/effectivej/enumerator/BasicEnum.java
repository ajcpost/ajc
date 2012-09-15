package aj.effectivej.enumerator;

import java.util.*;

//Enum type with constant-specific class bodies and data
public enum BasicEnum {
    PLUS("+") {
	@Override
	double apply(double x, double y) {
	    return x + y;
	}
    },
    MINUS("-") {
	@Override
	double apply(double x, double y) {
	    return x - y;
	}
    },
    TIMES("*") {
	@Override
	double apply(double x, double y) {
	    return x * y;
	}
    },
    DIVIDE("/") {
	@Override
	double apply(double x, double y) {
	    return x / y;
	}
    };
    private final String symbol;

    BasicEnum(String symbol) {
	this.symbol = symbol;
    }

    @Override
    public String toString() {
	return symbol;
    }

    abstract double apply(double x, double y);

    // Implementing a fromString method on an enum type - Page 154
    private static final Map<String, BasicEnum> stringToEnum = new HashMap<String, BasicEnum>();
    static { // Initialize map from constant name to enum constant
	for (BasicEnum op : values())
	    stringToEnum.put(op.toString(), op);
    }

    // Returns Operation for string, or null if string is invalid
    public static BasicEnum fromString(String symbol) {
	return stringToEnum.get(symbol);
    }

    // Test program to perform all operations on given operands
    public static void main(String[] args) {
	double x = Double.parseDouble(args[0]);
	double y = Double.parseDouble(args[1]);
	for (BasicEnum op : BasicEnum.values())
	    System.out.printf("%f %s %f = %f%n", x, op, y, op.apply(x, y));
    }
}
