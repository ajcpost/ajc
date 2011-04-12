package com.amber.A2;

import java.util.Calendar;

public class PrintMonth {

	private static final int S_FIRST_DAY = 1;

	public static void printMonth(int inputYear, int inputMonth) {

		// The default Calendar instance is "lenient", such that we can
		// (de/in)crement the date and it will take care of adjusting the
		// year/month appropriately.
		Calendar cal = Calendar.getInstance();

		// Set the calendar to input month & get max no. of days in that month
		cal.set(inputYear, inputMonth, S_FIRST_DAY);
		int lastDay = cal.getActualMaximum(Calendar.DATE);

		// If 1st day of the month doesn't fall on Monday, take the calendar
		// back by as many days.
		int backfill = 0;
		if (cal.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY) {
			backfill = 6;
		} else {
			backfill = cal.get(Calendar.DAY_OF_WEEK) - Calendar.MONDAY;
		}
		cal.set(Calendar.DATE, cal.get(Calendar.DATE) - backfill);

		// Ok, that's the starting point, we just need to sprint to the
		// finish line. Start by printing 7 days a line;
		boolean done = false;
		while (!done) {
			for (int i = 0; i < 7; i++) {
				int year = cal.get(Calendar.YEAR);
				int month = cal.get(Calendar.MONDAY);
				int day = cal.get(Calendar.DATE);
				System.out.print(year + "-" + (month + 1) + "/" + day + " ");
				cal.set(Calendar.DATE, day + 1);
				if (month == inputMonth && day == lastDay) {
					// We crossed the last day of the month but don't break
					// till we finish all of the week.
					done = true;
				}
			}
			System.out.println();
		}
	}

	public static void main(String[] args) {
		printMonth(2007, Calendar.DECEMBER);
	}

}
