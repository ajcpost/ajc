package aj.effectivej.enumerator;

//The strategy enum pattern. Hands-off the payroll computation to another private enum.
//The private enum is instantiated along with the outer public enum via additional data.s

enum StrategyEnum {
    MONDAY(PayType.WEEKDAY), TUESDAY(PayType.WEEKDAY), WEDNESDAY(
	    PayType.WEEKDAY), THURSDAY(PayType.WEEKDAY), FRIDAY(PayType.WEEKDAY), SATURDAY(
	    PayType.WEEKEND), SUNDAY(PayType.WEEKEND);

    private final PayType payType;

    StrategyEnum(PayType payType) {
	this.payType = payType;
    }

    double pay(double hoursWorked, double payRate) {
	return payType.pay(hoursWorked, payRate);
    }

    // The strategy enum type
    private enum PayType {
	WEEKDAY {
	    @Override
	    double overtimePay(double hours, double payRate) {
		return hours <= HOURS_PER_SHIFT ? 0 : (hours - HOURS_PER_SHIFT)
			* payRate / 2;
	    }
	},
	WEEKEND {
	    @Override
	    double overtimePay(double hours, double payRate) {
		return hours * payRate / 2;
	    }
	};
	private static final int HOURS_PER_SHIFT = 8;

	abstract double overtimePay(double hrs, double payRate);

	double pay(double hoursWorked, double payRate) {
	    double basePay = hoursWorked * payRate;
	    return basePay + overtimePay(hoursWorked, payRate);
	}
    }
}
