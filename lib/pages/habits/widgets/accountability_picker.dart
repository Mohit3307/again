import 'package:flutter/material.dart';

import 'package:again/core/models/contact.dart';

class AccountabilityPicker extends StatelessWidget {
  const AccountabilityPicker({
    super.key,
    required this.contacts,
    required this.selectedIds,
    required this.onChanged,
  });

  final List<Contact> contacts;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final result = await showDialog<List<String>>(
          context: context,
          builder: (context) {
            return _ContactDialog(
              contacts: contacts,
              selectedIds: selectedIds,
            );
          },
        );

        if (result != null) {
          onChanged(result);
        }
      },
      icon: const Icon(Icons.people_outline),
      label: Text(
        selectedIds.isEmpty
            ? 'Select accountability contacts'
            : '${selectedIds.length} contact(s) selected',
      ),
    );
  }
}

class _ContactDialog extends StatefulWidget {
  const _ContactDialog({
    required this.contacts,
    required this.selectedIds,
  });

  final List<Contact> contacts;
  final List<String> selectedIds;

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  late final List<String> selectedIds = [
    ...widget.selectedIds,
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Accountability'),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.contacts.isEmpty
            ? const Text('No contacts added yet.')
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final contact in widget.contacts)
                    CheckboxListTile(
                      value: selectedIds.contains(contact.id),
                      title: Text(contact.name),
                      subtitle: Text(contact.email),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            if (!selectedIds.contains(contact.id)) {
                              selectedIds.add(contact.id);
                            }
                          } else {
                            selectedIds.remove(contact.id);
                          }
                        });
                      },
                    ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              selectedIds,
            );
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}