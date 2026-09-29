import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:again/core/models/habit.dart';
import 'package:again/features/auth.dart';
import 'package:again/features/contacts.dart';
import 'package:again/features/habits.dart';

import 'package:again/pages/habits/templates/custom_form.dart';
import 'package:again/pages/habits/templates/fitness_form.dart';
import 'package:again/pages/habits/templates/health_form.dart';
import 'package:again/pages/habits/templates/productivity_form.dart';
import 'package:again/pages/habits/widgets/accountability_picker.dart';
import 'package:again/pages/habits/widgets/habit_schedule.dart';

class CreateHabitScreen extends HookConsumerWidget {
  const CreateHabitScreen({
    super.key,
    required this.type,
  });

  final String type;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final nameController =
        useTextEditingController();

    final notesController =
        useTextEditingController();

    final customTargetController =
        useTextEditingController();

    final templateDetails =
        useState<Map<String, dynamic>?>(null);

    final healthDuration =
        useState('30 days');

    final scheduledDays =
        useState<List<int>>([
      1,
      2,
      3,
      4,
      5,
      6,
      7,
    ]);

    final selectedTime =
        useState<TimeOfDay?>(null);

    final selectedContacts =
        useState<List<String>>([]);

    final uid =
        ref.read(authServiceProvider)
            .currentUser
            ?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text('You are not logged in.'),
        ),
      );
    }

    final contacts =
        ref.watch(contactsProvider(uid));

    Future<void> saveHabit() async {
      if (nameController.text
          .trim()
          .isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
                Text('Please enter a habit name.'),
          ),
        );
        return;
      }

      final details =
          templateDetails.value;

      final habit = Habit(
        id: '',
        name: nameController.text.trim(),
        type: type,
        feature: details?['feature'],
        notes:
            notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),

        reminderTime:
            selectedTime.value?.format(
          context,
        ),

        scheduledDays:
            scheduledDays.value,

        accountabilityContactIds:
            selectedContacts.value,

        sessionLength:
            details?['sessionLength'],

        focusLength:
            details?['focusLength'],

        breakLength:
            details?['breakLength'],

        cycles:
            details?['cycles'],

        details: type == 'Health'
            ? {
                'duration':
                    healthDuration.value,
              }
            : type == 'Custom'
                ? {
                    'target':
                        customTargetController
                            .text
                            .trim(),
                  }
                : details,
      );

      await ref
          .read(
            habitControllerProvider
                .notifier,
          )
          .addHabit(
            uid,
            habit,
          );

      if (context.mounted) {
        // Back to Select Habit Type.
        Navigator.pop(context);

        // Back to Home.
        Navigator.pop(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create $type Habit',
        ),
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(16),

        children: [
          TextField(
            controller:
                nameController,
            decoration:
                const InputDecoration(
              labelText:
                  'Habit name',
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller:
                notesController,
            maxLines: 2,
            decoration:
                const InputDecoration(
              labelText:
                  'Notes (optional)',
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          if (type == 'Productivity')
            ProductivityForm(
              onChanged: (value) {
                templateDetails
                    .value = value;
              },
            ),

          if (type == 'Fitness')
            FitnessForm(
              onChanged: (value) {
                templateDetails
                    .value = value;
              },
            ),

          if (type == 'Health')
            HealthForm(
              onChanged: (value) {
                healthDuration
                    .value = value;
              },
            ),

          if (type == 'Custom')
            CustomForm(
              controller:
                  customTargetController,
            ),

          const SizedBox(height: 28),

          HabitSchedule(
            onChanged: (
              days,
              time,
            ) {
              scheduledDays
                  .value = days;

              selectedTime
                  .value = time;
            },
          ),

          const SizedBox(height: 20),

          contacts.when(
            loading: () =>
                const Center(
              child:
                  CircularProgressIndicator(),
            ),

            error: (
              error,
              stackTrace,
            ) =>
                const Text(
              'Could not load contacts.',
            ),

            data: (
              contactList,
            ) =>
                AccountabilityPicker(
              contacts:
                  contactList,

              selectedIds:
                  selectedContacts.value,

              onChanged: (ids) {
                selectedContacts
                    .value = ids;
              },
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  saveHabit,
              child:
                  const Text(
                'Create Habit',
              ),
            ),
          ),
        ],
      ),
    );
  }
}