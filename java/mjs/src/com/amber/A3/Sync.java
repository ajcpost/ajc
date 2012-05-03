package com.amber.A3;

import java.util.Vector;

// "name" identifies a unique contact. If a name changes,
// client must delete the previous contact and create a new one.
// See Contact POJO for contact definition and ContactList for
// the in-memory storage of all Contacts

public class Sync {

	// Used only for incremental synchronization (updates, additions).
	// Can't be used when any contacts have been deleted.
	public static void syncUpdates(Vector<Contact> cv) {
		ContactList cl = ContactList.getInstance();

		for (int i = 0; i < cv.size(); i++) {
			cl.updateContact(cv.get(i));
		}
	}

	// Used for major changes (including delete)on the client side such
	// that creating a fresh list makes more sense than doing incremental
	// updates. Returns back the contacts which couldn't be added.
	public static Vector<Contact> syncBulk(Vector<Contact> cv) {
		ContactList cl = ContactList.getInstance();
		return cl.refresh(cv);
	}

	// Used for synchronizing deleted contacts on the client side.
	public static void syncDeletes(Vector<Contact> cv) {
		ContactList cl = ContactList.getInstance();
		for (int i = 0; i < cv.size(); i++) {
			cl.deleteContact(cv.get(i));
		}

	}

	public static void main(String[] args) {

		// Get the contact list instance. Empty initially.
		ContactList clist = ContactList.getInstance();

		// Create few contacts
		Contact c1 = new Contact("John", "222333");
		Contact c2 = new Contact("Ryan", "333444");
		Vector<Contact> cv = new Vector<Contact>();
		cv.add(c1);
		cv.add(c2);

		// Send the first list for syncing. It will all be fresh adds.
		syncUpdates(cv);
		clist.dump();

		// Create new contact, update an old one.
		Contact c3 = new Contact("John", "999999");
		Contact c4 = new Contact("Chris", "555555");
		cv.clear();
		cv.add(c3);
		cv.add(c4);

		// Send the second list for syncing. One fresh add, one update.
		syncUpdates(cv);
		clist.dump();

		// Sync one deleted contact
		Contact c5 = new Contact("Ryan", "333444");
		cv.clear();
		cv.add(c5);
		syncDeletes(cv);
		clist.dump();

		// Refresh the contact list with an empty list
		cv.clear();
		syncBulk(cv);
		clist.dump();
	}
}
