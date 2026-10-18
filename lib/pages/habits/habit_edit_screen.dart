import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:again/core/models/habit.dart';
import 'package:again/features/habits.dart';

class HabitEditScreen extends ConsumerStatefulWidget {
  const HabitEditScreen({
    super.key,
    required this.uid,
    required this.habit,
  });

  final String uid;
  final Habit habit;

  @override
  ConsumerState<HabitEditScreen> createState() =>
      _HabitEditScreenState();
}

class _HabitEditScreenState
    extends ConsumerState<HabitEditScreen> {
  late final TextEditingController nameController;
  late final TextEditingController notesController;

  late List<int> scheduledDays;
  late String? reminderTime;

  // Stored values use Monday = 1 ... Sunday = 7.
  // The UI displays Sunday first.
  static const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const dayValues = [7, 1, 2, 3, 4, 5, 6];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.habit.name,
    );

    notesController = TextEditingController(
      text: widget.habit.notes ?? '',
    );

    scheduledDays = List<int>.from(
      widget.habit.scheduledDays,
    );

    reminderTime = widget.habit.reminderTime;
  }

  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit name cannot be empty.'),
        ),
      );
      return;
    }

    final updatedHabit = Habit(
      id: widget.habit.id,
      name: name,
      type: widget.habit.type,
      feature: widget.habit.feature,
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
      reminderTime: reminderTime,
      scheduledDays: List<int>.from(scheduledDays),
      accountabilityContactIds:
          widget.habit.accountabilityContactIds,
      completedDates: widget.habit.completedDates,
      sessionLength: widget.habit.sessionLength,
      focusLength: widget.habit.focusLength,
      breakLength: widget.habit.breakLength,
      cycles: widget.habit.cycles,
      details: widget.habit.details,
    );

    try {
      await ref
          .read(habitControllerProvider.notifier)
          .updateHabit(widget.uid, updatedHabit);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save habit: $error'),
        ),
      );
    }
  }

  Future<void> selectTime() async {
    final initialTime = _parseInitialTime(reminderTime)
        ?? TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked == null || !mounted) return;

    setState(() {
      reminderTime =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  TimeOfDay? _parseInitialTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final text = value.trim();

    // Accept older values such as "6:45 AM".
    final amPmMatch = RegExp(
      r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$',
    ).firstMatch(text);

    if (amPmMatch != null) {
      var hour = int.parse(amPmMatch.group(1)!);
      final minute = int.parse(amPmMatch.group(2)!);
      final period = amPmMatch.group(3)!.toUpperCase();

      if (hour < 1 || hour > 12 || minute > 59) return null;

      if (period == 'AM') {
        hour = hour == 12 ? 0 : hour;
      } else {
        hour = hour == 12 ? 12 : hour + 12;
      }

      return TimeOfDay(hour: hour, minute: minute);
    }

    // New values use 24-hour HH:mm format.
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})$',
    ).firstMatch(text);

    if (match == null) return null;

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);

    if (hour > 23 || minute > 59) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  void toggleDay(int day) {
    setState(() {
      if (scheduledDays.contains(day)) {
        scheduledDays.remove(day);
      } else {
        scheduledDays.add(day);
      }

      scheduledDays.sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Habit name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Schedule',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < dayLabels.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    child: GestureDetector(
                      onTap: () => toggleDay(dayValues[i]),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            scheduledDays.contains(dayValues[i])
                                ? colors.primary
                                : Colors.transparent,
                        child: Text(
                          dayLabels[i],
                          style: TextStyle(
                            color: scheduledDays.contains(dayValues[i])
                                ? colors.onPrimary
                                : colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reminder time'),
            subtitle: Text(reminderTime ?? 'Not set'),
            trailing: const Icon(Icons.access_time),
            onTap: selectTime,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saveChanges,
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}