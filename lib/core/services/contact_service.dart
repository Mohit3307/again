import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:again/core/models/contact.dart';

class ContactService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _contacts(String uid) {
    return _db.collection('users').doc(uid).collection('contacts');
  }

  Stream<List<Contact>> getContacts(String uid) {
    return _contacts(uid).snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList(),
    );
  }

  Future<void> addContact(String uid, Contact contact) async {
    await _contacts(uid).add(contact.toFirestore());
  }

  Future<void> deleteContact(String uid, String contactId) async {
    await _contacts(uid).doc(contactId).delete();
  }
}
