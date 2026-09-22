import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:again/core/models/contact.dart';
import 'package:again/core/models/habit.dart';
import 'package:again/features/auth.dart';
import 'package:again/features/contacts.dart';
import 'package:again/features/habits.dart';

class CreateHabitScreen extends HookConsumerWidget {
  const CreateHabitScreen({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = useTextEditingController();
    final focusMinutes = useTextEditingController(text: '25');
    final breakMinutes = useTextEditingController(text: '5');
    final cycles = useTextEditingController(text: '4');
    final notes = useTextEditingController();

    final feature = useState('Focus session');
    final addNotes = useState(false);
    final reminder = useState<TimeOfDay?>(null);
    final selectedContacts = useState<List<String>>([]);
    final saving = useState(false);

    final user = ref.watch(authStateProvider).value;

    final contacts = user == null
        ? null
        : ref.watch(contactsProvider(user.uid));

    Future<void> save() async {
      if (user == null || name.text.trim().isEmpty || reminder.value == null) {
        return;
      }

      saving.value = true;

      try {
        final habit = Habit(
          id: '',
          name: name.text.trim(),
          type: type,
          feature: feature.value,
          notes: addNotes.value ? notes.text.trim() : null,
          reminderTime: reminder.value!.format(context),
          accountabilityContactIds: selectedContacts.value,

          sessionLength: feature.value == 'Focus session'
              ? int.tryParse(focusMinutes.text)
              : null,

          focusLength: feature.value == 'Pomodoro'
              ? int.tryParse(focusMinutes.text)
              : null,

          breakLength: feature.value == 'Pomodoro'
              ? int.tryParse(breakMinutes.text)
              : null,

          cycles: feature.value == 'Pomodoro'
              ? int.tryParse(cycles.text)
              : null,
        );

        await ref
            .read(habitControllerProvider.notifier)
            .addHabit(user.uid, habit);

        if (context.mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } finally {
        saving.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Habit'),
        actions: [
          TextButton(
            onPressed: saving.value ? null : save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Coding Session',
            ),
          ),

          const SizedBox(height: 24),

          Text('Features', style: Theme.of(context).textTheme.titleMedium),

          RadioListTile<String>(
            value: 'Focus session',
            groupValue: feature.value,
            title: const Text('Focus session'),
            subtitle: const Text('One focused session'),
            onChanged: (value) {
              feature.value = value!;
            },
          ),

          if (feature.value == 'Focus session')
            TextField(
              controller: focusMinutes,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Session length (minutes)',
              ),
            ),

          RadioListTile<String>(
            value: 'Pomodoro',
            groupValue: feature.value,
            title: const Text('Pomodoro'),
            subtitle: const Text('Focus + break cycles'),
            onChanged: (value) {
              feature.value = value!;
            },
          ),

          if (feature.value == 'Pomodoro') ...[
            TextField(
              controller: focusMinutes,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Focus time (minutes)',
              ),
            ),
            TextField(
              controller: breakMinutes,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Break time (minutes)',
              ),
            ),
            TextField(
              controller: cycles,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cycles'),
            ),
          ],

          const SizedBox(height: 16),

          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notes'),
            value: addNotes.value,
            onChanged: (value) {
              addNotes.value = value ?? false;
            },
          ),

          if (addNotes.value)
            TextField(
              controller: notes,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Add notes'),
            ),

          const SizedBox(height: 16),

          Row(
            children: [
              Text('Contacts', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                onPressed: contacts == null
                    ? null
                    : () =>
                          _selectContacts(context, contacts, selectedContacts),
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          Wrap(
            spacing: 8,
            children: [
              for (final contactId in selectedContacts.value)
                Chip(label: Text(contactId)),
            ],
          ),

          const SizedBox(height: 16),

          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reminder'),
            subtitle: Text(
              reminder.value == null
                  ? 'Choose a time'
                  : reminder.value!.format(context),
            ),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (picked != null) {
                reminder.value = picked;
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectContacts(
    BuildContext context,
    AsyncValue<List<Contact>> contacts,
    ValueNotifier<List<String>> selected,
  ) async {
    if (!contacts.hasValue) {
      return;
    }

    final contactList = contacts.value!;
    final current = {...selected.value};

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select contacts'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final contact in contactList)
                  CheckboxListTile(
                    title: Text(contact.name),
                    subtitle: Text(contact.email),
                    value: current.contains(contact.id),
                    onChanged: (value) {
                      if (value == true) {
                        current.add(contact.id);
                      } else {
                        current.remove(contact.id);
                      }

                      selected.value = [...current];
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
