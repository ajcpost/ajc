package com.amber.A3;

import java.util.Hashtable;
import java.util.Enumeration;
import java.util.Vector;

public class ContactList {
	private Hashtable<String, Contact> m_contacts = null;

	private static ContactList s_instance = null;

	// singleton
	private ContactList() {
		m_contacts = new Hashtable<String, Contact>();
	}

	public synchronized static ContactList getInstance() {
		if (null == s_instance) {
			s_instance = new ContactList();
		}
		return s_instance;
	}

	public synchronized void addContact(Contact c) {
		String name = c.getName();
		if (m_contacts.containsKey(name)) {
			throw new IllegalArgumentException("Contact by name " + name
					+ " already exists.");
		}
		m_contacts.put(name, c);
	}

	public synchronized Contact getContact(String name) {
		Contact c = m_contacts.get(name);
		if (null == c) {
			throw new IllegalArgumentException("Contact by name " + name
					+ " does not exists.");
		}
		return c;

	}

	public synchronized void deleteContact(Contact c) {
		m_contacts.remove(c.getName());
	}

	public synchronized void updateContact(Contact c) {
		Contact oldC = m_contacts.get(c.getName());
		if (null == oldC) {
			m_contacts.put(c.getName(), c);
		} else {
			oldC.clone(c);
		}
	}

	// Remove all old contacts and create a fresh list. Return back
	// the contacts that couldn't be added.
	public synchronized Vector<Contact> refresh(Vector<Contact> cv) {
		Vector<Contact> errorCv = new Vector<Contact>();

		// Clear the old contacts.
		m_contacts.clear();

		// Add all input, noting down the ones with error.
		for (int i = 0; i < cv.size(); i++) {
			Contact c = cv.get(i);
			try {
				addContact(c);
			} catch (IllegalArgumentException e) {
				errorCv.add(c);
			}
		}
		return errorCv;
	}

	public void dump() {
		System.out.println("----------------");
		System.out.println("Contact list has " + m_contacts.size()
				+ " contacts.");

		Enumeration<Contact> e = m_contacts.elements();
		int num = 1;
		while (e.hasMoreElements()) {
			Contact c = e.nextElement();
			System.out.println("Contact#" + num++ + " :  " + c.toString());
		}
		System.out.println("----------------");
	}
}