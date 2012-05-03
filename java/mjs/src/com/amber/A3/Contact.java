package com.amber.A3;

// Simple POJO for maintaing contact info
public class Contact {

	private String m_name;

	private String m_phone;

	public Contact(String name, String phone) {
		if (null == name) {
			throw new IllegalArgumentException("Name can't be null");
		}
		m_name = name;
		m_phone = phone;
	}

	public String getName() {
		return m_name;
	}

	public String getPhone() {
		return m_phone;
	}

	public void setName(String name) {
		if (null == name) {
			throw new IllegalArgumentException("Name can't be null");
		}
		m_name = name;
	}

	public void setPhone(String phone) {
		m_phone = phone;
	}

	public void clone(Contact c) {
		// No copy of name. Name is always a unique identifier for contact.
		m_phone = c.getPhone();
	}

	public String toString() {
		StringBuffer output = new StringBuffer();
		output.append("Name- ");
		output.append(m_name);
		output.append(" Phone- ");
		output.append(m_phone);
		return output.toString();
	}
}
