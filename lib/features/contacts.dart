import 'dart:async';

import 'package:again/core/models/contact.dart';
import 'package:again/core/services/contact_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'contacts.g.dart';

@riverpod
ContactService contactService(Ref ref) {
  return ContactService();
}

@riverpod
Stream<List<Contact>> contacts(Ref ref, String uid) {
  return ref.watch(contactServiceProvider).getContacts(uid);
}

@riverpod
class ContactController extends _$ContactController {
  @override
  FutureOr<void> build() {}

  Future<void> addContact(String uid, Contact contact) async {
    await ref.read(contactServiceProvider).addContact(uid, contact);
  }

  Future<void> deleteContact(String uid, String contactId) async {
    await ref.read(contactServiceProvider).deleteContact(uid, contactId);
  }
}
