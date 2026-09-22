import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:again/core/models/contact.dart';
import 'package:again/features/contacts.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider(uid));

    return contacts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (contacts) {
        return Stack(
          children: [
            if (contacts.isEmpty)
              const Center(child: Text('No contacts yet.'))
            else
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Contacts',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  for (final contact in contacts)
                    _ContactTile(contact: contact, uid: uid),
                ],
              ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () => _showAddContact(context, ref),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddContact(BuildContext context, WidgetRef ref) {
    final name = TextEditingController();
    final email = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (name.text.trim().isEmpty || email.text.trim().isEmpty) {
                  return;
                }

                final contact = Contact(
                  id: '',
                  name: name.text.trim(),
                  email: email.text.trim(),
                );

                await ref
                    .read(contactControllerProvider.notifier)
                    .addContact(uid, contact);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class _ContactTile extends ConsumerWidget {
  const _ContactTile({required this.contact, required this.uid});

  final Contact contact;
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(contact.name),
      subtitle: Text(contact.email),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () {
          ref
              .read(contactControllerProvider.notifier)
              .deleteContact(uid, contact.id);
        },
      ),
    );
  }
}
