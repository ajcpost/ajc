package com.symt;

public class Task {
	private static final int NEW = 0;
	private static final int TAKEN = 1;
	private static final int COMPLETED = 2;
	private static final int TIMEOUT = 2;

	private Object m_data;
	private int m_taskStatus = NEW;

	// Restrict access
	private Task() {
	}

	public Task(Object data) throws IllegalArgumentException {
		if (data == null) {
			throw new IllegalArgumentException("Null input");
		}
		m_data = data;
		m_taskStatus = NEW;
	}

	public Object getData() {
		return m_data;
	}

	protected boolean isNew() {
		if (NEW == m_taskStatus) {
			return true;
		}
		return false;
	}

	protected boolean isTaken() {
		if (TAKEN == m_taskStatus) {
			return true;
		}
		return false;
	}

	protected void setTaken() {
		m_taskStatus = TAKEN;
	}

	protected boolean isCompleted() {
		if (COMPLETED == m_taskStatus) {
			return true;
		}
		return false;
	}
	protected void setCompleted() {
		m_taskStatus = COMPLETED;
	}

	protected boolean isInterrupted() {
		if (TIMEOUT == m_taskStatus) {
			return true;
		}
		return false;
	}
	protected void setInterrupted() {
		m_taskStatus = TIMEOUT;
	}
}