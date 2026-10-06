import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:again/core/models/habit.dart';
import 'package:again/features/habits.dart';

class HabitEditScreen extends ConsumerStatefulWidget {
  const HabitEditScreen({super.key, required this.uid, required this.habit});

  final String uid;
  final Habit habit;

  @override
  ConsumerState<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends ConsumerState<HabitEditScreen> {
  late final TextEditingController nameController;
  late final TextEditingController notesController;

  late List<int> scheduledDays;
  late String? reminderTime;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.habit.name);

    notesController = TextEditingController(text: widget.habit.notes ?? '');

    scheduledDays = List<int>.from(widget.habit.scheduledDays);

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
        const SnackBar(content: Text('Habit name cannot be empty.')),
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
      scheduledDays: scheduledDays,
      accountabilityContactIds: widget.habit.accountabilityContactIds,
      completedDates: widget.habit.completedDates,
      sessionLength: widget.habit.sessionLength,
      focusLength: widget.habit.focusLength,
      breakLength: widget.habit.breakLength,
      cycles: widget.habit.cycles,
      details: widget.habit.details,
    );

    await ref
        .read(habitControllerProvider.notifier)
        .updateHabit(widget.uid, updatedHabit);

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> selectTime() async {
    TimeOfDay initialTime = TimeOfDay.now();

    if (reminderTime != null) {
      final parts = reminderTime!.split(':');

      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);

        if (hour != null && minute != null) {
          initialTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked == null) return;

    setState(() {
      reminderTime =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';
    });
  }

  void toggleDay(int day) {
    setState(() {
      if (scheduledDays.contains(day)) {
        scheduledDays.remove(day);
      } else {
        scheduledDays.add(day);
        scheduledDays.sort();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Habit')),
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

          Text('Schedule', style: Theme.of(context).textTheme.titleMedium),

          const SizedBox(height: 12),

          Row(
            children: [
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => toggleDay(i + 1),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: scheduledDays.contains(i + 1)
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        child: Text(
                          dayLabels[i],
                          style: TextStyle(
                            color: scheduledDays.contains(i + 1)
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
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
